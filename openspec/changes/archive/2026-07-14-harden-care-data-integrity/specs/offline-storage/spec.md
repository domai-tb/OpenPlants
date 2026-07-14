## ADDED Requirements

### Requirement: Persisted collection corruption is preserved and reported
Every SharedPreferences-backed collection SHALL distinguish an absent key from unreadable or invalid stored content. The system MUST preserve the raw stored value and report a classified persistence failure when JSON, top-level collection shape, schema migration, or record decoding fails.

#### Scenario: Missing collection is empty
- **WHEN** a collection key does not exist
- **THEN** the data source returns an empty collection without error

#### Scenario: Malformed JSON is reported
- **WHEN** a collection key contains malformed JSON
- **THEN** the data source reports a classified decode failure identifying the collection
- **AND** leaves the raw stored value unchanged

#### Scenario: Wrong top-level shape is reported
- **WHEN** a collection key contains valid JSON that is not the expected list shape
- **THEN** the data source reports a classified shape failure
- **AND** leaves the raw stored value unchanged

#### Scenario: Invalid record is reported without partial save
- **WHEN** one record in a stored collection cannot be decoded or migrated
- **THEN** the data source reports the failing record index
- **AND** does not return a partial collection as writable state
- **AND** leaves every raw record unchanged

#### Scenario: Mutation after failed load is blocked
- **WHEN** an add, update, or delete operation cannot first load its collection without a persistence failure
- **THEN** the operation fails without writing a replacement collection

#### Scenario: Known older schema is migrated
- **WHEN** a stored record matches a supported older schema
- **THEN** the data source migrates and decodes the record without discarding unrelated records
