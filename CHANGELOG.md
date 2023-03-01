# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- new `trace_request_selections` option to enable tracing root level GraphQL selections, which will be stored under `graphql.request.selections`

### Changed

* `OpentelemetryAbsinthe.setup` can now optionally recieve the configuration. Previously `OpentelemetryAbsinthe.Instrumentation.setup` had to be used.
* opentelemetry_absinthe will no longer log sensitive information by default.
  By default the graphql.request.variables, graphql.response.errors and graphql.response.result attributes will no longer be emited.
  The previous behavior can be restored by setting the opentelemetry_absinthe configuration options.

## [1.1.0] - 2022-09-21

### Changed

- opentelemetry_absinthe does not set opentelemetry-related Logger metadata anymore, because
  The OpenTelemetry API/SDK itself [does that automatically since 1.1.0](https://github.com/open-telemetry/opentelemetry-erlang/pull/394).
  If you're upgrading to opentelemetry_absinthe 1.1.0, it is therefore recommended to also upgrade to OpenTelemetry API 1.1.0
  in order to keep the opentelemetry log metadata.

[Unreleased]: https://github.com/primait/opentelemetry_absinthe/compare/1.1.0...HEAD
[1.1.0]: https://github.com/primait/opentelemetry_absinthe/releases/tag/1.1.0
