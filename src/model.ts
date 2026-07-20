import { readFile, readdir } from "node:fs/promises";
import path from "node:path";
import YAML from "yaml";
import { z } from "zod";

const StringList = z.array(z.string());

export const BuildingSchema = z.object({
  schema_version: z.literal(1),
  id: z.string().min(1),
  name: z.string().min(1),
  purpose: z.string().min(1),
  owns: StringList,
  accepts: StringList,
  produces: StringList,
  never: StringList,
  runtime_policy: z.string().min(1),
});

export const ActorSchema = z.object({
  schema_version: z.literal(1),
  id: z.string().min(1),
  owner: z.string().min(1),
  identity_key: z.string().min(1),
  owns: StringList,
  accepts: StringList,
  produces: StringList.optional().default([]),
});

const TransitionSchema = z.object({
  from: z.string(),
  on: z.string().min(1),
  to: z.string().min(1),
  effects: StringList.optional().default([]),
  emits: StringList.optional().default([]),
});

export const MachineSchema = z.object({
  schema_version: z.literal(1),
  id: z.string().min(1),
  actor: z.string().min(1),
  initial: z.string().min(1),
  states: StringList.min(1),
  terminal: StringList,
  transitions: z.array(TransitionSchema).min(1),
  invariants: StringList,
});

const ProductStepSchema = z.object({
  id: z.string().min(1),
  owner: z.string().min(1),
  actor: z.string().nullable(),
  proof: z.string().min(1),
});

export const ProductSchema = z.object({
  schema_version: z.literal(1),
  id: z.string().min(1),
  promise: z.string().min(1),
  inputs: z.array(z.object({
    id: z.string().min(1),
    required: z.boolean(),
    description: z.string().min(1),
  })),
  artifact: z.object({
    id: z.string().min(1),
    owner: z.string().min(1),
    kind: z.literal("data"),
    presentation_owner: z.string().min(1),
    fields: StringList.min(1),
  }),
  golden_path: z.array(ProductStepSchema).min(1),
  transport: z.object({
    active: z.string().min(1),
    deferred: StringList,
  }),
  optional_lanes: z.array(z.object({
    id: z.string().min(1),
    after: z.string().min(1),
    required: z.boolean(),
  })),
  never: StringList,
});

export type Building = z.infer<typeof BuildingSchema>;
export type Actor = z.infer<typeof ActorSchema>;
export type Machine = z.infer<typeof MachineSchema>;
export type Product = z.infer<typeof ProductSchema>;

async function parseYaml<T>(file: string, schema: z.ZodType<T>): Promise<T> {
  const raw = await readFile(file, "utf8");
  const value = YAML.parse(raw);
  return schema.parse(value);
}

async function loadYamlDir<T>(dir: string, schema: z.ZodType<T>): Promise<T[]> {
  const files = (await readdir(dir))
    .filter((file) => file.endsWith(".yaml"))
    .sort();
  return Promise.all(files.map((file) => parseYaml(path.join(dir, file), schema)));
}

export interface Blueprint {
  product: Product;
  buildings: Building[];
  actors: Actor[];
  machines: Machine[];
}

export async function loadBlueprint(root = process.cwd()): Promise<Blueprint> {
  const product = await parseYaml(path.join(root, "intent/product.yaml"), ProductSchema);
  const buildings = await loadYamlDir(path.join(root, "intent/buildings"), BuildingSchema);
  const actors = await loadYamlDir(path.join(root, "intent/actors"), ActorSchema);
  const machines = await loadYamlDir(path.join(root, "intent/machines"), MachineSchema);
  return { product, buildings, actors, machines };
}

function duplicates(values: string[]): string[] {
  const seen = new Set<string>();
  const duplicate = new Set<string>();
  for (const value of values) {
    if (seen.has(value)) duplicate.add(value);
    seen.add(value);
  }
  return [...duplicate].sort();
}

export function validateBlueprint(blueprint: Blueprint): string[] {
  const errors: string[] = [];
  const buildingIds = new Set(blueprint.buildings.map((item) => item.id));
  const actorIds = new Set(blueprint.actors.map((item) => item.id));

  for (const id of duplicates(blueprint.buildings.map((item) => item.id))) {
    errors.push(`duplicate building id: ${id}`);
  }
  for (const id of duplicates(blueprint.actors.map((item) => item.id))) {
    errors.push(`duplicate actor id: ${id}`);
  }
  for (const id of duplicates(blueprint.machines.map((item) => item.id))) {
    errors.push(`duplicate machine id: ${id}`);
  }

  const nounOwners = new Map<string, string>();
  for (const building of blueprint.buildings) {
    for (const noun of building.owns) {
      const prior = nounOwners.get(noun);
      if (prior && prior !== building.id) {
        errors.push(`durable noun ${noun} has multiple building owners: ${prior}, ${building.id}`);
      }
      nounOwners.set(noun, building.id);
    }
  }

  for (const actor of blueprint.actors) {
    if (!buildingIds.has(actor.owner)) {
      errors.push(`actor ${actor.id} references missing owner ${actor.owner}`);
    }
  }

  for (const machine of blueprint.machines) {
    if (!actorIds.has(machine.actor)) {
      errors.push(`machine ${machine.id} references missing actor ${machine.actor}`);
    }
    const states = new Set(machine.states);
    if (!states.has(machine.initial)) {
      errors.push(`machine ${machine.id} initial state ${machine.initial} is undeclared`);
    }
    for (const terminal of machine.terminal) {
      if (!states.has(terminal)) errors.push(`machine ${machine.id} terminal ${terminal} is undeclared`);
    }
    for (const transition of machine.transitions) {
      if (!states.has(transition.from)) {
        errors.push(`machine ${machine.id} transition from ${transition.from} is undeclared`);
      }
      if (!states.has(transition.to)) {
        errors.push(`machine ${machine.id} transition to ${transition.to} is undeclared`);
      }
    }
  }

  for (const step of blueprint.product.golden_path) {
    if (!buildingIds.has(step.owner)) {
      errors.push(`product step ${step.id} references missing building ${step.owner}`);
    }
    if (step.actor && !actorIds.has(step.actor)) {
      errors.push(`product step ${step.id} references missing actor ${step.actor}`);
    }
  }

  if (!buildingIds.has(blueprint.product.artifact.owner)) {
    errors.push(`artifact owner ${blueprint.product.artifact.owner} is missing`);
  }
  if (!buildingIds.has(blueprint.product.artifact.presentation_owner)) {
    errors.push(`artifact presentation owner ${blueprint.product.artifact.presentation_owner} is missing`);
  }

  const dashboard = blueprint.buildings.find((item) => item.id === "dashboard");
  if (!dashboard) errors.push("dashboard building is required");
  if (dashboard && dashboard.owns.length > 0) errors.push("dashboard must own no durable domain nouns");

  const sonar = blueprint.buildings.find((item) => item.id === "sonar");
  if (!sonar?.produces.includes("ownership.ready")) {
    errors.push("sonar must produce ownership.ready");
  }
  if (sonar?.produces.includes("catalog.confirmed")) {
    errors.push("sonar may not produce catalog.confirmed");
  }

  if (blueprint.product.transport.active !== "http-pull") {
    errors.push("MVP active transport must remain http-pull");
  }

  const neverText = blueprint.product.never.join(" ").toLowerCase();
  if (!neverText.includes("score catalog active")) {
    errors.push("product never-list must protect Score catalog active from Sonar readiness");
  }
  if (!neverText.includes("registry scoring")) {
    errors.push("product never-list must protect Registry Scoring from order progress");
  }

  return errors;
}
