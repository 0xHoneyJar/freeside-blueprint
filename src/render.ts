import { mkdir, writeFile } from "node:fs/promises";
import path from "node:path";
import { loadBlueprint, validateBlueprint, type Blueprint, type Machine } from "./model.js";

function safe(value: string): string {
  return value.replace(/[^a-zA-Z0-9_]/g, "_");
}

function label(value: string): string {
  return value.replaceAll("-", " ");
}

function productFlow(blueprint: Blueprint): string {
  const lines = ["flowchart LR"];
  blueprint.product.golden_path.forEach((step, index) => {
    const node = `S${index}`;
    lines.push(`  ${node}["${label(step.id)}\\nowner: ${step.owner}\\nproof: ${step.proof}"]`);
    if (index > 0) lines.push(`  S${index - 1} --> ${node}`);
  });
  return `${lines.join("\n")}\n`;
}

function actorMap(blueprint: Blueprint): string {
  const lines = ["flowchart LR"];
  for (const building of blueprint.buildings) {
    const buildingNode = `B_${safe(building.id)}`;
    lines.push(`  ${buildingNode}["${building.name}"]`);
    for (const actor of blueprint.actors.filter((item) => item.owner === building.id)) {
      const actorNode = `A_${safe(actor.id)}`;
      lines.push(`  ${actorNode}(("${label(actor.id)}\\n${actor.identity_key}"))`);
      lines.push(`  ${buildingNode} --> ${actorNode}`);
    }
  }
  return `${lines.join("\n")}\n`;
}

function stateMachine(machine: Machine): string {
  const lines = ["stateDiagram-v2", `  [*] --> ${safe(machine.initial)}`];
  for (const transition of machine.transitions) {
    lines.push(`  ${safe(transition.from)} --> ${safe(transition.to)}: ${transition.on}`);
  }
  for (const terminal of machine.terminal) lines.push(`  ${safe(terminal)} --> [*]`);
  return `${lines.join("\n")}\n`;
}

function systemMarkdown(blueprint: Blueprint): string {
  const buildingRows = blueprint.buildings
    .map((b) => `| ${b.name} | ${b.purpose} | ${b.owns.join(", ") || "none"} |`)
    .join("\n");
  const actorRows = blueprint.actors
    .map((a) => `| ${label(a.id)} | ${a.owner} | ${a.identity_key} | ${a.owns.join(", ")} |`)
    .join("\n");
  const pathRows = blueprint.product.golden_path
    .map((step, index) => `${index + 1}. **${label(step.id)}** — owner: \`${step.owner}\`; proof: \`${step.proof}\``)
    .join("\n");

  return `# Freeside active system\n\n> Generated view. Non-authoritative.\n\n## Product\n\n**${blueprint.product.id}** — ${blueprint.product.promise.trim()}\n\nArtifact: \`${blueprint.product.artifact.id}\` (${blueprint.product.artifact.kind}), owned by \`${blueprint.product.artifact.owner}\`; presentation owned by \`${blueprint.product.artifact.presentation_owner}\`.\n\n## Golden path\n\n${pathRows}\n\n## Buildings\n\n| Building | Purpose | Durable nouns |\n|---|---|---|\n${buildingRows}\n\n## Product actors\n\n| Actor | Owner | Identity | Owns |\n|---|---|---|---|\n${actorRows}\n\n## Active transport\n\n\`${blueprint.product.transport.active}\`\n\nDeferred: ${blueprint.product.transport.deferred.map((item) => `\`${item}\``).join(", ") || "none"}.\n\n## Never\n\n${blueprint.product.never.map((item) => `- ${item}`).join("\n")}\n`;
}

const root = process.cwd();
const blueprint = await loadBlueprint(root);
const errors = validateBlueprint(blueprint);
if (errors.length > 0) throw new Error(`Cannot render invalid blueprint:\n${errors.join("\n")}`);

const generated = path.join(root, "generated");
const machinesDir = path.join(generated, "state-machines");
await mkdir(machinesDir, { recursive: true });
await writeFile(path.join(generated, "SYSTEM.md"), systemMarkdown(blueprint));
await writeFile(path.join(generated, "product-flow.mmd"), productFlow(blueprint));
await writeFile(path.join(generated, "actor-map.mmd"), actorMap(blueprint));
for (const machine of blueprint.machines) {
  await writeFile(path.join(machinesDir, `${machine.id}.mmd`), stateMachine(machine));
}

console.log(`Rendered ${2 + blueprint.machines.length} Mermaid/Markdown views under generated/.`);
