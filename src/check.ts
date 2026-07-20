import { loadBlueprint, validateBlueprint } from "./model.js";

const blueprint = await loadBlueprint();
const errors = validateBlueprint(blueprint);

if (errors.length > 0) {
  console.error("Blueprint validation failed:\n");
  for (const error of errors) console.error(`- ${error}`);
  process.exit(1);
}

console.log(
  `Blueprint valid: ${blueprint.buildings.length} buildings, ${blueprint.actors.length} actors, ${blueprint.machines.length} machines.`,
);
