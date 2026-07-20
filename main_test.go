package main

import "testing"

func TestBlueprint(t *testing.T) {
	b, err := load()
	if err != nil {
		t.Fatal(err)
	}
	if err := validate(b); err != nil {
		t.Fatal(err)
	}
	proof, err := prove(b)
	if err != nil {
		t.Fatal(err)
	}
	if !proof.OK {
		t.Fatal("proof failed")
	}
}

func TestIllegalTransition(t *testing.T) {
	b, _ := load()
	if _, err := step(b.Machines["order"], "requested", "ArtifactProduced"); err == nil {
		t.Fatal("illegal transition accepted")
	}
}
