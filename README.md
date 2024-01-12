# swift-elasticsearch-query-builder

Status: Experimental / In Progress

A simple DSL to make it easier to construct Elasticsearch queries in Swift.

## Goals

* Builder Syntax supporting conditionals and loops
* Simple typing system for scalar values
* Doesn't try to define the whole syntax language, just enough to provide structure.

## Examples

Static

```swift
@ElasticsearchQueryBuilder 
func build() -> some esb.QueryDSL {
    esb.Query {
        esb.Bool {
            esb.Key("match_bool_prefix") {
                [
                    "message": "quick brown f"
                ]
            }
        }
    }
    esb.Pagination.init(size: 20)
}
```

Conditionals

```swift
@ElasticsearchQueryBuilder 
func build(message: String?) -> some esb.QueryDSL {
    esb.Query {
        esb.Bool {
            if let message { 
                esb.Key("match") {
                    [
                        "message": .string(message)
                    ]
                }
            }
        }
    }
}
```

Loops

```swift
@ElasticsearchQueryBuilder 
func build(messages: [String]) -> some esb.QueryDSL {
    esb.Query {
        esb.Bool {
            esb.Should {
                for message in messages {
                    esb.Key("match") {
                        [
                            "message": .string(message)
                        ]
                    }
                }
            }
        }
    }
}
```

## License

This library is released under the MIT license. See LICENSE for details.
