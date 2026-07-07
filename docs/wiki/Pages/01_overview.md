# Pages Overview

The app has 5 feature tabs plus a "More" tab. Each feature follows the same Clean Architecture pattern:

- UI in `lib/pages/<feature>/<feature>_page.dart`
- A `DataSource` that simulates I/O
- A `Repository` that wraps the datasource
- A `Usecases` class that the UI calls

