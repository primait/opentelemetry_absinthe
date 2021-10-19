import Config

config :opentelemetry,
  tracer: :otel_tracer_default,
  processors: [{:otel_batch_processor, %{scheduled_delay_ms: 1}}]
