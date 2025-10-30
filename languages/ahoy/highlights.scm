; Comments
(comment) @comment

; Keywords
[
  "if"
  "then"
  "else"
  "anif"
  "loop"
  "do"
  "to"
  "from"
  "in"
  "till"
  "switch"
  "on"
  "return"
  "import"
  "when"
  "struct"
  "type"
  "enum"
  "program"
] @keyword

; Control flow statements
(break_statement) @keyword
(skip_statement) @keyword

; Function declarations - highlight the function name
(function_declaration
  name: (identifier) @function)

; Constant declarations - highlight as constants (orange)
(constant_declaration
  name: (identifier) @constant)

; Function calls - highlight function names  
(call_expression
  function: (identifier) @function)

; Method calls
(method_call
  method: (identifier) @function.method)

; Built-in types
(type) @type.builtin

; Struct declarations
(struct_declaration
  name: (identifier) @type)

; Enum declarations  
(enum_declaration
  name: (identifier) @type)

; Parameters
(parameter
  name: (identifier) @variable.parameter)

; Operators
[
  "+"
  "-"
  "*"
  "/"
  "%"
  ">"
  "<"
  ">="
  "<="
  "is"
  "and"
  "or"
  "not"
  "plus"
  "minus"
  "times"
  "div"
  "mod"
  "greater_than"
  "less_than"
] @operator

; Punctuation
[
  ":"
  "::"
  ";"
  ","
  "|"
] @punctuation.delimiter

[
  "("
  ")"
  "{"
  "}"
  "["
  "]"
] @punctuation.bracket

; Literals
(string) @string
(char) @string.special
(number) @number
(boolean) @constant.builtin

; Identifiers (default - will be overridden by more specific matches above)
(identifier) @variable
