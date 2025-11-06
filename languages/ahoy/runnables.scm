; Program declaration - main entry point
((program_declaration
  name: (identifier) @run
)
(#set! tag ahoy-program))

; Function declarations - can be run individually
((function_declaration
  name: (identifier) @run
)
(#set! tag ahoy-function))
