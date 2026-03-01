# Smart Bus Admin — Web Dashboard

Next.js admin dashboard for viewing **bus sensor** and **passenger health** analytics in the browser.

## Run locally

```bash
cd web-admin
npm install
npm run dev
```

Open [http://localhost:3000](http://localhost:3000).

## Pages

- **Dashboard** (`/`) — Status, KPIs, quick links to bus and passengers.
- **Bus sensors** (`/bus`) — Acceleration magnitude chart, speed chart, event log (collision, sharp_brake, etc.).
- **Passengers** (`/passengers`) — Passenger list with HR, SpO2, temp, conditions, route.

## Data

Currently uses **sample data** in `lib/data.ts` (same structure as the Flutter app CSVs). You can later:

- Add API routes that read from your backend or CSV uploads.
- Replace `busSensorData` and `passengerHealthData` with `fetch()` from your API.

## Build for production

```bash
npm run build
npm start
```
