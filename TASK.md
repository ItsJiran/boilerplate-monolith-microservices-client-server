# Web & Mobile Boilerplate + Integration

**Objective**: Create a robust boilerplate for Web (Vike+React) and Mobile (Expo) that integrates with Infrastructure services (Laravel API, Redis/Sockets, Scheduler).

## Phase 1: Web Server (Express + Vike)
- [x] **Express Entrypoint**: Create a custom Express server for the Web App.
- [x] **Session Spoofing**: Implement logic to forward User Sessions (Cookies/Tokens) from the Node server to the Laravel Backend during SSR.
- [x] **Infrastructure Integration**:
    - [x] Socket.io / Reverb connection setup.
    - [x] Scheduler/Queue dashboard (if applicable).

## Phase 2: Mobile Boilerplate
- [x] **Expo Setup**: Ensure clean Expo setup with Path Aliases.
- [x] **Native Integration**:
    - [x] Authentication Flow.
    - [ ] Push Notifications (Future).

## Phase 3: Shared Infrastructure
- [x] **API Client Adaptation**: Ensure `@repo/common` handles both Client-side (Zustand) and Server-side (Headers) auth.
