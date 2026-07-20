import assert from "node:assert/strict";
import { access, readFile } from "node:fs/promises";
import path from "node:path";
import { loadBlueprint, validateBlueprint } from "./model.js";

const root = process.cwd();
const blueprint = await loadBlueprint(root);
assert.deepEqual(validateBlueprint(blueprint), []);

assert.equal(blueprint.product.artifact.kind, "data");
assert.equal(blueprint.product.artifact.owner, "ordering");
assert.equal(blueprint.product.transport.active, "http-pull");
assert.ok(blueprint.product.artifact.fields.includes("stale_access_risk_estimate"));
assert.ok(blueprint.product.artifact.fields.includes("shadow_access_audit_cta"));

const dashboard = blueprint.buildings.find((item) => item.id === "dashboard");
assert.ok(dashboard);
assert.deepEqual(dashboard.owns, []);

const sonar = blueprint.buildings.find((item) => item.id === "sonar");
assert.ok(sonar?.produces.includes("ownership.ready"));
assert.ok(!sonar?.produces.includes("catalog.confirmed"));

await access(path.join(root, "generated/SYSTEM.md"));
const generated = await readFile(path.join(root, "generated/SYSTEM.md"), "utf8");
assert.match(generated, /contract-access-risk-audit/);
assert.match(generated, /http-pull/);

console.log("Reference implementation tests passed.");
