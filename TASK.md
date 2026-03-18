# Web & Mobile Boilerplate + Integration

**Objective**: Create a robust boilerplate for Web (Vike+React) and Mobile (Expo) that integrates with Infrastructure services (Laravel API, Redis/Sockets, Scheduler).

## Phase 1: Web Server (Express + Vike)
- [ ] **Express Entrypoint**: Create a custom Express server for the Web App.
- [ ] **Session Spoofing**: Implement logic to forward User Sessions (Cookies/Tokens) from the Node server to the Laravel Backend during SSR.
- [ ] **Infrastructure Integration**:
    - [ ] Socket.io / Reverb connection setup.
    - [ ] Scheduler/Queue dashboard (if applicable).

## Phase 2: Mobile Boilerplate
- [ ] **Expo Setup**: Ensure clean Expo setup with Path Aliases.
- [ ] **Native Integration**:
    - [ ] Authentication Flow.
    - [ ] Push Notifications (Future).

## Phase 3: Shared Infrastructure
- [ ] **API Client Adaptation**: Ensure `@repo/common` handles both Client-side (Zustand) and Server-side (Headers) auth.
