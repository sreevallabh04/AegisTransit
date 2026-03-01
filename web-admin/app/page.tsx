"use client";

import Link from "next/link";
import {
  busSensorData,
  passengerHealthData,
  getEventCounts,
  getAccelMagnitude,
} from "@/lib/data";

export default function DashboardPage() {
  const eventCounts = getEventCounts(busSensorData);
  const hasAccident = busSensorData.some(
    (r) =>
      r.eventLabel === "collision" ||
      r.eventLabel === "sharp_brake" ||
      r.eventLabel === "rollover"
  );
  const collisionCount = eventCounts["collision"] ?? 0;
  const peakReading = busSensorData.reduce((a, b) => {
    const magA = getAccelMagnitude(a);
    const magB = getAccelMagnitude(b);
    return magB > magA ? b : a;
  });
  const peakMagnitude = getAccelMagnitude(peakReading);

  return (
    <div className="mx-auto max-w-7xl px-4 py-8 sm:px-6">
      <div className="mb-8 animate-fade-in">
        <h1 className="text-3xl font-bold tracking-tight text-white">
          Dashboard
        </h1>
        <p className="mt-1 text-slate-400">
          Overview of bus sensors and passenger health
        </p>
      </div>

      {/* Status banner */}
      <div
        className={`mb-8 rounded-2xl border px-6 py-4 animate-slide-up ${
          hasAccident
            ? "border-red-500/50 bg-red-500/10"
            : "border-bus-500/30 bg-bus-500/10"
        }`}
      >
        <div className="flex items-center gap-3">
          <span className="text-3xl">{hasAccident ? "⚠️" : "✓"}</span>
          <div>
            <p className="font-semibold text-white">
              {hasAccident ? "Incident detected" : "All systems normal"}
            </p>
            <p className="text-sm text-slate-400">
              {hasAccident
                ? `Collision/sharp brake events recorded. Peak acceleration: ${peakMagnitude.toFixed(1)} m/s²`
                : "No accident events in current data."}
            </p>
          </div>
        </div>
      </div>

      {/* KPI cards */}
      <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
        <StatCard
          label="Bus readings"
          value={busSensorData.length}
          sub="sensor samples"
        />
        <StatCard
          label="Passengers"
          value={passengerHealthData.length}
          sub="on board"
        />
        <StatCard
          label="Events"
          value={Object.entries(eventCounts).length}
          sub={
            Object.entries(eventCounts)
              .map(([k, v]) => `${k}: ${v}`)
              .join(", ") || "none"
          }
        />
        <StatCard
          label="Peak accel"
          value={`${peakMagnitude.toFixed(1)} m/s²`}
          sub={peakReading.eventLabel}
        />
      </div>

      {/* Quick links */}
      <div className="mt-10 grid gap-6 sm:grid-cols-2">
        <Link
          href="/bus"
          className="group rounded-2xl border border-slate-800 bg-slate-900/50 p-6 transition hover:border-bus-500/50 hover:bg-slate-900"
        >
          <h2 className="text-lg font-semibold text-white group-hover:text-bus-400">
            Bus sensors →
          </h2>
          <p className="mt-1 text-sm text-slate-400">
            Acceleration, gyro, alcohol, event timeline
          </p>
        </Link>
        <Link
          href="/passengers"
          className="group rounded-2xl border border-slate-800 bg-slate-900/50 p-6 transition hover:border-bus-500/50 hover:bg-slate-900"
        >
          <h2 className="text-lg font-semibold text-white group-hover:text-bus-400">
            Passengers →
          </h2>
          <p className="mt-1 text-sm text-slate-400">
            Heart rate, SpO2, conditions, destinations
          </p>
        </Link>
      </div>
    </div>
  );
}

function StatCard({
  label,
  value,
  sub,
}: {
  label: string;
  value: string | number;
  sub: string;
}) {
  return (
    <div className="animate-slide-up rounded-2xl border border-slate-800 bg-slate-900/50 p-5">
      <p className="text-sm font-medium text-slate-400">{label}</p>
      <p className="mt-1 text-2xl font-bold text-white">{value}</p>
      <p className="mt-0.5 truncate text-xs text-slate-500">{sub}</p>
    </div>
  );
}
