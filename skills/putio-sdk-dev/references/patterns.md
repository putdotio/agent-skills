# SDK Patterns

Use these examples when a put.io SDK repo needs concrete implementation shape and the repo does not already establish a stronger local pattern.

## TypeScript

Keep boundary parsing explicit and keep Promise and Effect surfaces aligned:

```ts
const FileSchema = Schema.Struct({
  id: Schema.Number,
  name: Schema.String,
  content_type: Schema.NullOr(Schema.String),
});

export type PutioFile = Schema.Schema.Type<typeof FileSchema>;

export const listFiles = (client: PutioSdkClient, input: ListFilesInput) =>
  client.get("/files/list", { query: input }).pipe(
    selectJsonField("files"),
    Effect.flatMap(Schema.decodeUnknown(Schema.Array(FileSchema))),
    withOperationErrors(ListFilesErrorSpec),
  );
```

Prefer discriminated unions and parameter-aware types over loose bags:

```ts
type SubtitleResult =
  | { readonly kind: "available"; readonly subtitles: ReadonlyArray<Subtitle> }
  | { readonly kind: "missing" };
```

Use `Schema` at boundaries so casts, ignored type failures, and ad hoc JSON parsing stay out of the public path.

Expose ergonomic helpers on top of typed errors so consumers can reuse the same checks:

```ts
export const isAuthError = (error: PutioSdkError): boolean =>
  error._tag === "ApiError" && error.code === "invalid_token";

export const getLocalizedError = (error: PutioSdkError): string =>
  localizePutioError(error).summary;
```

Model pagination and query-dependent response shapes explicitly:

```ts
type PageInput = {
  readonly perPage?: number;
  readonly cursor?: string;
};

type ListFilesInput<IncludeParent extends boolean = false> = PageInput & {
  readonly parentId?: number;
  readonly includeParent?: IncludeParent;
};

type ListFilesResult<IncludeParent extends boolean> = {
  readonly files: ReadonlyArray<PutioFile>;
  readonly cursor: string | null;
} & (IncludeParent extends true
  ? { readonly parent: PutioFile | null }
  : { readonly parent?: never });
```

## Kotlin

Model backend state with explicit types and tolerate forward-compatible backend values where needed:

```kotlin
@Serializable
data class PutioFile(
    val id: Long,
    val name: String,
    @SerialName("content_type") val contentType: String? = null,
)

@JvmInline
@Serializable(with = PutioFileTypeSerializer::class)
value class PutioFileType(val raw: String) {
    val isKnown: Boolean get() = raw in setOf("VIDEO", "AUDIO", "FOLDER")
}
```

Keep coroutine APIs domain-first and keep request, response, and error models updated together.

Expose helpers around typed exceptions when they materially improve app code:

```kotlin
fun PutioException.isRetryable(): Boolean =
    this is PutioException.Transport || this is PutioException.RateLimited

fun PutioException.userMessage(localizer: PutioErrorLocalizer): String =
    localizer.localize(this).summary
```

Prefer explicit pagination and query models over raw maps:

```kotlin
@Serializable
data class PageCursor(
    val cursor: String? = null,
    @SerialName("per_page") val perPage: Int? = null,
)

@Serializable
data class ListFilesQuery(
    @SerialName("parent_id") val parentId: Long? = null,
    val cursor: String? = null,
)
```

When an SDK or CLI offers "collect all pages", bound it with max pages/items and reject repeated cursors. Streaming pagination still needs cursor-cycle detection even when it does not accumulate every item in memory.

## Swift

Keep public contracts explicit and preserve a stable package surface:

```swift
public struct AccountInfo: Decodable, Sendable {
    public let username: String
    public let mail: String
}

public enum PutioSDKError: Error, Sendable {
    case transport(TransportError)
    case api(status: Int, message: String)
    case decoding(DecodingError)
}
```

Use the example app for auth-flow and integration smoke checks when a formal live harness is not available yet.

Expose small adapters around typed errors when apps need them:

```swift
extension PutioSDKError: LocalizedError {
    public var errorDescription: String? { localizedSummary }
}

extension PutioSDKError {
    public var isRetryable: Bool {
        switch self {
        case .transport: true
        default: false
        }
    }
}
```

Prefer explicit query and pagination types over `[String: Any]`-style bags:

```swift
public struct PageCursor: Sendable, Equatable {
    public let cursor: String?
    public let perPage: Int?
}

public struct ListFilesQuery: Sendable, Equatable {
    public let parentId: Int64?
    public let cursor: String?
    public let includeParent: Bool
}
```

## Verification Layers

Healthy SDK repos should keep two layers distinct:

- Unit or contract tests for request shaping, parsing, error mapping, and multi-client alignment
- Safe live tests for real API behavior, conditional backend fields, and reversible mutations

Representative shapes in this workspace:

```bash
vp run verify
vp run test:live
./gradlew verify
./gradlew liveTest
make verify
```

If a repo only has one layer today, document the gap and prefer adding the missing layer over widening claims about verification quality.
