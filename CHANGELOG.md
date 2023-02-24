# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.2.0] - 2023-02-24

### Added

- new `trace_request_selections` option to enable tracing root level GraphQL selections, which will be stored under `graphql.request.selections`

## [1.1.0] - 2022-09-21

### Changed

- opentelemetry_absinthe does not set opentelemetry-related Logger metadata anymore, because
  The OpenTelemetry API/SDK itself [does that automatically since 1.1.0](https://github.com/open-telemetry/opentelemetry-erlang/pull/394).
  If you're upgrading to opentelemetry_absinthe 1.1.0, it is therefore recommended to also upgrade to OpenTelemetry API 1.1.0
  in order to keep the opentelemetry log metadata.

[Unreleased]: https://github.com/primait/opentelemetry_absinthe/compare/1.2.0...HEAD
[1.2.0]: https://github.com/primait/opentelemetry_absinthe/compare/1.1.0...1.2.0
[1.1.0]: https://github.com/primait/opentelemetry_absinthe/releases/tag/1.1.0
