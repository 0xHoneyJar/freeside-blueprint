# 0002 — Shared preparation and capacity are not product concepts

Status: proposed

The operator does not currently require simultaneous-order work sharing or capacity admission. Demand observability is satisfied by durable AuditOrder rows and metrics.

Existing shared-preparation and capacity machinery may remain as reliability code, but it is hidden from the default architecture and must prove a live constraint before becoming required by the MVP.

This is not deletion authorization.
