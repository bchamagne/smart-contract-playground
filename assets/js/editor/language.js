export async function setLanguage(monaco) {

  // we are actually extending the elixir language provided by Monaco
  const monarchObject = {
    tokenizer: {
      root: [
        { include: 'customArchethic' },
      ],
      customArchethic: [
        [
          /\b(hash|regex_match\?|regex_extract|json_extract|set_type|add_uco_transfer|add_token_transfer|set_content|set_code|add_ownership|add_recipient)\b/,
          [
            'keyword.archethicFunction',
          ]
        ],
        [
          /\b(condition|actions|export|fun)\b/,
          [
            'keyword.archethicDeclaration',
          ]
        ],
      ],
    },
  }

  await updateLanguage(monarchObject);

  monaco.languages.registerCompletionItemProvider('elixir', {
    provideCompletionItems: () => {
      var suggestions = [
        {
          label: 'fun',
          kind: monaco.languages.CompletionItemKind.Snippet,
          insertText: "fun ${1:function_name}(${2:}) do\n\t${3:}\nend",
          insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
          documentation: 'Declares a private function'
        },
        {
          label: 'export fun',
          kind: monaco.languages.CompletionItemKind.Snippet,
          insertText: "export fun ${1:function_name}(${2:}) do\n\t${3:}\nend",
          insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
          documentation: 'Declares a public function'
        },
        {
          label: 'actions triggered_by interval',
          kind: monaco.languages.CompletionItemKind.Snippet,
          insertText: [
            '# ┌───────────── minute (0 - 59)',
            '# │ ┌───────────── hour (0 - 23)',
            '# │ │ ┌───────────── day of the month (1 - 31)',
            '# │ │ │ ┌───────────── month (1 - 12)',
            '# │ │ │ │ ┌───────────── day of the week (0 - 6) (Sunday to Saturday)',
            '# │ │ │ │ │',
            '# │ │ │ │ │',
            '# │ │ │ │ │',
            '# * * * * *',
            'actions triggered_by: interval, at: "${1:0 * * * *}" do', '\t', 'end'].join('\n'),
          insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
          documentation: 'Actions triggered on the given interval (cron-style)'
        },
        {
          label: 'actions triggered_by datetime',
          kind: monaco.languages.CompletionItemKind.Snippet,
          insertText: ['actions triggered_by: datetime, at: ${1:timestamp} do', '\t', 'end'].join('\n'),
          insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
          documentation: 'Actions triggered at the given timestamp'
        },

        {
          label: 'actions triggered_by oracle',
          kind: monaco.languages.CompletionItemKind.Snippet,
          insertText: [
            'condition triggered_by: oracle, as: []',
            'actions triggered_by: oracle do', '\t', 'end'].join('\n'),
          insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
          documentation: 'Actions triggered at the given timestamp'
        },
        {
          label: 'actions triggered_by transaction',
          kind: monaco.languages.CompletionItemKind.Snippet,
          insertText: [
            'condition triggered_by: transaction, as: []',
            'actions triggered_by: transaction do', '\t', 'end'].join('\n'),
          insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
          documentation: 'Actions triggered by an incoming transaction'
        },
        {
          label: 'actions triggered_by transaction on',
          kind: monaco.languages.CompletionItemKind.Snippet,
          insertText: [
            'condition triggered_by: transaction, on: ${1:function_name}(${2}), as: []',
            'actions triggered_by: transaction, on: ${1:function_name}(${2}) do', '\t', 'end'].join('\n'),
          insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
          documentation: 'Actions triggered by an incoming transaction with a named action'
        },
        // Contract
        {
          label: 'Contract.add_uco_transfer/2',
          kind: monaco.languages.CompletionItemKind.Snippet,
          insertText: 'Contract.add_uco_transfer to: ${1:0x0000...}, amount: ${2:amount}',
          insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
          documentation: 'Adds a UCO transfer'
        },
        {
          label: 'Contract.add_uco_transfers/1',
          kind: monaco.languages.CompletionItemKind.Snippet,
          insertText: 'Contract.add_uco_transfers [\n\t[to: ${1:0x0000...}, amount: ${2:amount}],\n\t[to: ${3:0x0000...}, amount: ${4:amount}]\n]',
          insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
          documentation: 'Adds multiple UCO transfers'
        },
        {
          label: 'Contract.add_token_transfer/3',
          kind: monaco.languages.CompletionItemKind.Snippet,
          insertText: 'Contract.add_token_transfer to: ${1:0x0000...}, token_address: ${2:0x0000...}, amount: ${3:amount}',
          insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
          documentation: 'Adds a token transfer'
        },
        {
          label: 'Contract.add_token_transfer/4',
          kind: monaco.languages.CompletionItemKind.Snippet,
          insertText: 'Contract.add_token_transfer to: ${1:0x0000...}, token_address: ${2:0x0000...}, amount: ${3:amount}, token_id: ${4:1}',
          insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
          documentation: 'Adds a token transfer'
        },
        {
          label: 'Contract.add_token_transfers/1',
          kind: monaco.languages.CompletionItemKind.Snippet,
          insertText: 'Contract.add_token_transfers [\n\t[to: ${1:0x0000...}, token_address: ${2:0x0000...}, amount: ${3:amount}],\n\t[to: ${4:0x0000...}, token_address: ${5:0x0000...}, amount: ${6:amount}]\n]',
          insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
          documentation: 'Adds multiple token transfers'
        },
        {
          label: 'Contract.add_recipient/1',
          kind: monaco.languages.CompletionItemKind.Snippet,
          insertText: 'Contract.add_recipient "${1:0x0000...}"',
          insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
          documentation: 'Adds a recipient'
        },
        {
          label: 'Contract.add_recipient/3',
          kind: monaco.languages.CompletionItemKind.Snippet,
          insertText: 'Contract.add_recipient address: "${1:0x0000...}", action: "${2:vote}", args: ["${3:John}"]',
          insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
          documentation: 'Adds a recipient'
        },
        {
          label: 'Contract.add_recipients/1',
          kind: monaco.languages.CompletionItemKind.Snippet,
          insertText: 'Contract.add_recipients [\n\t[address: "${1:0x0000...}", action: "${2:vote}", args: ["${3:John}"]],\n\t[address: "${4:0x0000...}", action: "${5:vote}", args: ["${6:John}"]]\n]',
          insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
          documentation: 'Adds multiple contracts\' recipients'
        },
        {
          label: 'Contract.set_type/1',
          kind: monaco.languages.CompletionItemKind.Snippet,
          insertText: 'Contract.set_type "${1:transfer}"',
          insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
          documentation: 'Sets the next transaction\'s type'
        },
        {
          label: 'Contract.set_content/1',
          kind: monaco.languages.CompletionItemKind.Snippet,
          insertText: 'Contract.set_content "${1:}"',
          insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
          documentation: 'Sets the next transaction\'s content'
        },
        {
          label: 'Contract.set_code/1',
          kind: monaco.languages.CompletionItemKind.Snippet,
          insertText: 'Contract.set_code "${1:}"',
          insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
          documentation: 'Sets the next transaction\'s code'
        },
        {
          label: 'Contract.call_function/3',
          kind: monaco.languages.CompletionItemKind.Snippet,
          insertText: 'Contract.call_function ${1:0x0000...}, "${2:function}", [${3:}]',
          insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
          documentation: 'Calls an external contract public function'
        },
        // Crypto
        {
          label: 'Crypto.hash/1',
          kind: monaco.languages.CompletionItemKind.Snippet,
          insertText: 'Crypto.hash "${1:}"',
          insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
          documentation: 'Hashes the given string'
        },
        {
          label: 'Crypto.hash/2',
          kind: monaco.languages.CompletionItemKind.Snippet,
          insertText: 'Crypto.hash "${1:}" "${2:sha256}"',
          insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
          documentation: 'Hashes the given string with given algorithm'
        },
        // Chain
        {
          label: 'Chain.get_genesis_address/1',
          kind: monaco.languages.CompletionItemKind.Snippet,
          insertText: 'Chain.get_genesis_address ${1:0x0000...}',
          insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
          documentation: 'Retrieves the genesis address of given address'
        },
        {
          label: 'Chain.get_first_transaction_address/1',
          kind: monaco.languages.CompletionItemKind.Snippet,
          insertText: 'Chain.get_first_transaction_address ${1:0x0000...}',
          insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
          documentation: 'Retrieves the first transaction\'s address of the chain containing given address'
        },
        {
          label: 'Chain.get_genesis_public_key/1',
          kind: monaco.languages.CompletionItemKind.Snippet,
          insertText: 'Chain.get_genesis_public_key ${1:0x0000...}',
          insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
          documentation: 'Retrieves the genesis public key of given public key'
        },
        {
          label: 'Chain.get_transaction/1',
          kind: monaco.languages.CompletionItemKind.Snippet,
          insertText: 'Chain.get_transaction ${1:0x0000...}',
          insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
          documentation: 'Retrieves the transaction at given address'
        },
        {
          label: 'Chain.get_burn_address/0',
          kind: monaco.languages.CompletionItemKind.Snippet,
          insertText: 'Chain.get_burn_address()',
          insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
          documentation: 'Returns the burn address'
        },
        // Code
        {
          label: 'Code.is_same?/2',
          kind: monaco.languages.CompletionItemKind.Snippet,
          insertText: 'Code.is_same? "${1:}", "${2:}"',
          insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
          documentation: 'Compares two code strings via their internal representation'
        },
        {
          label: 'Code.is_valid?/1',
          kind: monaco.languages.CompletionItemKind.Snippet,
          insertText: 'Code.is_valid? "${1:}"',
          insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
          documentation: 'Returns true if the code parses, false otherwise'
        },
        // Http
        {
          label: 'Http.fetch/1',
          kind: monaco.languages.CompletionItemKind.Snippet,
          insertText: 'Http.fetch "${1:https://}"',
          insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
          documentation: 'Fetches the URL via a GET and returns the status and body'
        },
        {
          label: 'Http.fetch_many/1',
          kind: monaco.languages.CompletionItemKind.Snippet,
          insertText: 'Http.fetch_many [\n\t"${1:https://}",\n\t"${2:https://}"\n]',
          insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
          documentation: 'Fetches up to 5 URLs in parallel and returns the statues and bodies'
        },
        // Json
        {
          label: 'Json.path_extract/2',
          kind: monaco.languages.CompletionItemKind.Snippet,
          insertText: 'Json.path_extract ${1:json}, "$.firstName"',
          insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
          documentation: 'Extracts a value from the given JSON by it\'s path'
        },
        {
          label: 'Json.path_match?/2',
          kind: monaco.languages.CompletionItemKind.Snippet,
          insertText: 'Json.path_match? ${1:json}, "$.firstName"',
          insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
          documentation: 'Returns wether there is a value at given path or not'
        },
        {
          label: 'Json.to_string/2',
          kind: monaco.languages.CompletionItemKind.Snippet,
          insertText: 'Json.to_string ${1:}',
          insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
          documentation: 'Converts the given term to JSON'
        },
        {
          label: 'Json.parse/1',
          kind: monaco.languages.CompletionItemKind.Snippet,
          insertText: 'Json.parse ${1:json}',
          insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
          documentation: 'Converts the given JSON to term'
        },
        {
          label: 'Json.is_valid?/1',
          kind: monaco.languages.CompletionItemKind.Snippet,
          insertText: 'Json.is_valid? ${1:json}',
          insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
          documentation: 'Returns wether the given JSON is valid or not'
        },
        // Regex
        {
          label: 'Regex.extract/2',
          kind: monaco.languages.CompletionItemKind.Snippet,
          insertText: 'Regex.extract ${1:data}, "${2:^[0-9]+$}"',
          insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
          documentation: 'Extracts the value from given data matching the given regex'
        },
        {
          label: 'Regex.match?/2',
          kind: monaco.languages.CompletionItemKind.Snippet,
          insertText: 'Regex.match? ${1:data}, "${2:^[0-9]+$}"',
          insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
          documentation: 'Returns wether the given pattern matches with given data'
        },
        {
          label: 'Regex.scan/2',
          kind: monaco.languages.CompletionItemKind.Snippet,
          insertText: 'Regex.scan ${1:data}, "${2:^([0-9]+)$}"',
          insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
          documentation: 'Similar to extract/2 but returns the captured groups'
        },
        // String
        {
          label: 'String.size/1',
          kind: monaco.languages.CompletionItemKind.Snippet,
          insertText: 'String.size ${1:}',
          insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
          documentation: 'Returns the number of characters of given string'
        },
        {
          label: 'String.in?/2',
          kind: monaco.languages.CompletionItemKind.Snippet,
          insertText: 'String.in? ${1:haystack}, "${2:needle}"',
          insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
          documentation: 'Returns wether the needle is in the haystack or not'
        },
        {
          label: 'String.to_number/1',
          kind: monaco.languages.CompletionItemKind.Snippet,
          insertText: 'String.to_number ${1:}',
          insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
          documentation: 'Converts the given string to a number'
        },
        {
          label: 'String.from_number/1',
          kind: monaco.languages.CompletionItemKind.Snippet,
          insertText: 'String.from_number ${1:}',
          insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
          documentation: 'Converts the given number to a string'
        },
        {
          label: 'String.to_hex/1',
          kind: monaco.languages.CompletionItemKind.Snippet,
          insertText: 'String.to_hex ${1:}',
          insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
          documentation: 'Converts the given string to an hexadecimal'
        },
        {
          label: 'String.to_uppercase/1',
          kind: monaco.languages.CompletionItemKind.Snippet,
          insertText: 'String.to_uppercase ${1:}',
          insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
          documentation: 'Transforms all characters of given string to uppercase'
        },
        {
          label: 'String.to_lowercase/1',
          kind: monaco.languages.CompletionItemKind.Snippet,
          insertText: 'String.to_lowercase ${1:}',
          insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
          documentation: 'Transforms all characters of given string to lowercase'
        },
        // List
        {
          label: 'List.at/2',
          kind: monaco.languages.CompletionItemKind.Snippet,
          insertText: 'List.at ${1:list}, ${2:0}',
          insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
          documentation: 'Returns the element at given index or nil'
        },
        {
          label: 'List.size/1',
          kind: monaco.languages.CompletionItemKind.Snippet,
          insertText: 'List.size ${1:}',
          insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
          documentation: 'Returns the list\'s length'
        },
        {
          label: 'List.in?/2',
          kind: monaco.languages.CompletionItemKind.Snippet,
          insertText: 'List.in? ${1:haystack}, {2:needle}',
          insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
          documentation: 'Returns wether the needle is in the haystack or not'
        },
        {
          label: 'List.empty?/2',
          kind: monaco.languages.CompletionItemKind.Snippet,
          insertText: 'List.empty? ${1:}',
          insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
          documentation: 'Returns wether the list is empty or not'
        },
        {
          label: 'List.concat/2',
          kind: monaco.languages.CompletionItemKind.Snippet,
          insertText: 'List.concat ${1:list1}, ${2:list2}',
          insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
          documentation: 'Concatenates both lists'
        },
        {
          label: 'List.append/2',
          kind: monaco.languages.CompletionItemKind.Snippet,
          insertText: 'List.append ${1:list}, ${2:elem}',
          insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
          documentation: 'Append given element at the end of the given list'
        },
        {
          label: 'List.preprend/2',
          kind: monaco.languages.CompletionItemKind.Snippet,
          insertText: 'List.preprend ${1:list}, ${2:elem}',
          insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
          documentation: 'Append given element at the beginning of the given list'
        },
        {
          label: 'List.join/2',
          kind: monaco.languages.CompletionItemKind.Snippet,
          insertText: 'List.join ${1:list}, "${2:,}"',
          insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
          documentation: 'Joins a list of string with given separator'
        },
        // Map
        {
          label: 'Map.new/0',
          kind: monaco.languages.CompletionItemKind.Snippet,
          insertText: 'Map.new()',
          insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
          documentation: 'Creates an empty map'
        },
        {
          label: 'Map.size/1',
          kind: monaco.languages.CompletionItemKind.Snippet,
          insertText: 'Map.size ${1:}',
          insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
          documentation: 'Returns the count of map keys'
        },
        {
          label: 'Map.get/2',
          kind: monaco.languages.CompletionItemKind.Snippet,
          insertText: 'Map.get ${1:map}, "${2:key}"',
          insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
          documentation: 'Returns the value in given map at given key'
        },
        {
          label: 'Map.get/3',
          kind: monaco.languages.CompletionItemKind.Snippet,
          insertText: 'Map.get ${1:map}, "${2:key}", "default value"',
          insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
          documentation: 'Returns the value in given map at given key (with a default value)'
        },
        {
          label: 'Map.set/3',
          kind: monaco.languages.CompletionItemKind.Snippet,
          insertText: 'Map.get ${1:map}, "${2:key}", ${3:value}',
          insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
          documentation: 'Updates given map by setting given value at given key'
        },
        {
          label: 'Map.keys/1',
          kind: monaco.languages.CompletionItemKind.Snippet,
          insertText: 'Map.keys ${1:}',
          insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
          documentation: 'Returns the map keys'
        },
        {
          label: 'Map.values/1',
          kind: monaco.languages.CompletionItemKind.Snippet,
          insertText: 'Map.values ${1:}',
          insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
          documentation: 'Returns the map values'
        },
        // Time
        {
          label: 'Time.now/0',
          kind: monaco.languages.CompletionItemKind.Snippet,
          insertText: 'Time.now()',
          insertTextRules: monaco.languages.CompletionItemInsertTextRule.InsertAsSnippet,
          documentation: 'Returns an approximation of current time (will always return the same value)'
        },

      ];
      return { suggestions: suggestions };
    }
  });
};

async function updateLanguage(monarchObject) {
  const allLangs = monaco.languages.getLanguages();
  const { conf, language: elixirLang } = await allLangs.find(({ id }) => id === 'elixir').loader();
  for (let key in monarchObject) {
    const value = monarchObject[key];
    if (key === 'tokenizer') {
      for (let category in value) {
        const tokenDefs = value[category];
        if (!elixirLang.tokenizer.hasOwnProperty(category)) {
          elixirLang.tokenizer[category] = [];
        }
        if (Array.isArray(tokenDefs)) {
          elixirLang.tokenizer[category].unshift.apply(elixirLang.tokenizer[category], tokenDefs)
        }
      }
    } else if (Array.isArray(value)) {
      if (!elixirLang.hasOwnProperty(key)) {
        elixirLang[key] = [];
      }
      elixirLang[key].unshift.apply(elixirLang[key], value)
    }
  }
}
