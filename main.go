package main

import (
	_ "embed"
	"encoding/json"
	"errors"
	"fmt"
	"os"
	"sort"
)

//go:embed blueprint.json
var raw []byte

type Building struct {
	Owns []string `json:"owns"`
}
type Machine struct {
	Owner       string                       `json:"owner"`
	Initial     string                       `json:"initial"`
	States      []string                     `json:"states"`
	Transitions map[string]map[string]string `json:"transitions"`
}
type Scenario struct {
	Messages [][2]string       `json:"messages"`
	Expect   map[string]string `json:"expect"`
}
type Blueprint struct {
	SchemaVersion int `json:"schema_version"`
	Product       struct {
		ID        string   `json:"id"`
		Promise   string   `json:"promise"`
		Transport string   `json:"transport"`
		Path      []string `json:"path"`
	} `json:"product"`
	Buildings map[string]Building `json:"buildings"`
	Machines  map[string]Machine  `json:"machines"`
	Scenarios map[string]Scenario `json:"scenarios"`
}
type Receipt struct{ Machine, Before, Message, After string }
type ScenarioProof struct {
	OK       bool              `json:"ok"`
	States   map[string]string `json:"states"`
	Receipts []Receipt         `json:"receipts"`
}
type Proof struct {
	OK        bool                     `json:"ok"`
	Product   string                   `json:"product"`
	Scenarios map[string]ScenarioProof `json:"scenarios"`
}

func load() (Blueprint, error) {
	var b Blueprint
	return b, json.Unmarshal(raw, &b)
}

func set(xs []string) map[string]bool {
	m := make(map[string]bool, len(xs))
	for _, x := range xs {
		m[x] = true
	}
	return m
}

func validate(b Blueprint) error {
	var errs []error
	if b.SchemaVersion != 1 {
		errs = append(errs, errors.New("schema_version must be 1"))
	}
	if b.Product.Transport != "http-pull" {
		errs = append(errs, errors.New("MVP transport must be http-pull"))
	}
	if len(b.Buildings["dashboard"].Owns) != 0 {
		errs = append(errs, errors.New("dashboard must own no durable state"))
	}

	owners := map[string]string{}
	for id, building := range b.Buildings {
		for _, noun := range building.Owns {
			if previous := owners[noun]; previous != "" {
				errs = append(errs, fmt.Errorf("%s owned by %s and %s", noun, previous, id))
			}
			owners[noun] = id
		}
	}
	for _, owner := range b.Product.Path {
		if _, ok := b.Buildings[owner]; !ok {
			errs = append(errs, fmt.Errorf("unknown path owner %s", owner))
		}
	}
	for id, machine := range b.Machines {
		states := set(machine.States)
		if _, ok := b.Buildings[machine.Owner]; !ok {
			errs = append(errs, fmt.Errorf("machine %s has unknown owner", id))
		}
		if !states[machine.Initial] {
			errs = append(errs, fmt.Errorf("machine %s has unknown initial state", id))
		}
		for from, messages := range machine.Transitions {
			if !states[from] {
				errs = append(errs, fmt.Errorf("machine %s has unknown from state %s", id, from))
			}
			for _, to := range messages {
				if !states[to] {
					errs = append(errs, fmt.Errorf("machine %s has unknown to state %s", id, to))
				}
			}
		}
	}
	return errors.Join(errs...)
}

func step(machine Machine, state, message string) (string, error) {
	next, ok := machine.Transitions[state][message]
	if !ok {
		return "", fmt.Errorf("illegal transition: %s + %s", state, message)
	}
	return next, nil
}

func run(b Blueprint, s Scenario) (ScenarioProof, error) {
	states := map[string]string{}
	for id, machine := range b.Machines {
		states[id] = machine.Initial
	}
	proof := ScenarioProof{States: states}
	for _, message := range s.Messages {
		id, event := message[0], message[1]
		machine, ok := b.Machines[id]
		if !ok {
			return proof, fmt.Errorf("unknown machine %s", id)
		}
		before := states[id]
		after, err := step(machine, before, event)
		if err != nil {
			return proof, fmt.Errorf("%s: %w", id, err)
		}
		states[id] = after
		proof.Receipts = append(proof.Receipts, Receipt{id, before, event, after})
	}
	proof.OK = true
	for id, want := range s.Expect {
		proof.OK = proof.OK && states[id] == want
	}
	return proof, nil
}

func prove(b Blueprint) (Proof, error) {
	proof := Proof{OK: true, Product: b.Product.ID, Scenarios: map[string]ScenarioProof{}}
	names := make([]string, 0, len(b.Scenarios))
	for name := range b.Scenarios {
		names = append(names, name)
	}
	sort.Strings(names)
	for _, name := range names {
		result, err := run(b, b.Scenarios[name])
		if err != nil {
			return proof, fmt.Errorf("scenario %s: %w", name, err)
		}
		proof.Scenarios[name] = result
		proof.OK = proof.OK && result.OK
	}
	return proof, nil
}

func main() {
	b, err := load()
	if err == nil {
		err = validate(b)
	}
	var proof Proof
	if err == nil {
		proof, err = prove(b)
	}
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
	out, _ := json.MarshalIndent(proof, "", "  ")
	fmt.Println(string(out))
	if !proof.OK {
		os.Exit(1)
	}
}
