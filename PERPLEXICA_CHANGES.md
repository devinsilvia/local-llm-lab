# Perplexica Submodule Changes

- Added upload cache reuse by hashing file content and reusing existing extracted text/embeddings when the same file + embedding model + chunk settings are used.
- Introduced a public `getCacheKey()` on embeddings so cache keys are derived without reaching into protected config.
- Added Markdown uploads (`.md` / `text/markdown`) and inferred MIME types for `application/octet-stream` uploads based on file extension.
- Reduced the rendered prompt size in the message header.
- Forced search to run when file attachments are present so uploaded file context is used.
- Fixed suggestions API to accept both tuple and object chat history formats.
- Allowed `.md` in both attachment pickers (regular and compact).
- Added an uploads API route and source linking so uploaded file citations open via `/api/uploads/<fileId>`.
- Added `typing_extensions` to the SearxNG venv install in the Perplexica Dockerfile to satisfy runtime dependencies.
- Hardened Research Progress rendering against malformed step payloads to avoid client crashes.
- Added chat/message IDs to researcher tool execution context and standardized logging for invalid search payloads.
- Added API search logging for researcher startup with chat/message IDs.
- Fixed streaming tool-call argument handling so partial chunks are merged and parsed before execution.
- Normalized tool-call arguments with JSON repair before executing researcher actions.
- Added search error steps so invalid query payloads surface in the Research Progress UI instead of crashing searches.
- Added query coercion for search tools so stringified query lists are parsed into arrays when possible.

Files touched inside the submodule:

- `perplexica/Dockerfile`
- `perplexica/src/lib/uploads/manager.ts`
- `perplexica/src/lib/models/base/embedding.ts`
- `perplexica/src/components/MessageInputActions/Attach.tsx`
- `perplexica/src/components/MessageInputActions/AttachSmall.tsx`
- `perplexica/src/components/MessageBox.tsx`
- `perplexica/src/components/MessageSources.tsx`
- `perplexica/src/components/AssistantSteps.tsx`
- `perplexica/src/app/api/uploads/[fileId]/route.ts`
- `perplexica/src/lib/agents/search/index.ts`
- `perplexica/src/lib/agents/search/api.ts`
- `perplexica/src/lib/agents/search/types.ts`
- `perplexica/src/lib/agents/search/researcher/index.ts`
- `perplexica/src/lib/agents/search/researcher/actions/uploadsSearch.ts`
- `perplexica/src/lib/agents/search/researcher/actions/webSearch.ts`
- `perplexica/src/lib/agents/search/researcher/actions/academicSearch.ts`
- `perplexica/src/lib/agents/search/researcher/actions/socialSearch.ts`
- `perplexica/src/lib/agents/search/researcher/actions/registry.ts`
- `perplexica/src/lib/types.ts`
- `perplexica/src/app/api/suggestions/route.ts`
