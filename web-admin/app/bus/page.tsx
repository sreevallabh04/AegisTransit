"use client";

import {
  LineChart,
  Line,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
  Area,
  AreaChart,
} from "recharts";
import {
  busSensorData,
  getAccelMagnitude,
  getEventCounts,
} from "@/lib/data";

export default function BusPage() {
  const chartData = busSensorData.map((r) => ({
    time: r.timestamp.slice(11, 19),
    magnitude: Math.round(getAccelMagnitude(r) * 100) / 100,
    speed: r.speedKmh,
    event: r.eventLabel,
  }));
  const eventCounts = getEventCounts(busSensorData);
  const hasCollision = busSensorData.some((r) => r.eventLabel === "collision");

  return (
    <div className="mx-auto max-w-7xl px-4 py-8 sm:px-6">
      <div className="mb-8">
        <h1 className="text-3xl font-bold tracking-tight text-white">
          Bus sensors
        </h1>
        <p className="mt-1 text-slate-400">
          MPU6050 acceleration, gyro, alcohol — ESP32 stream
        </p>
      </div>

      <div className="mb-8 flex flex-wrap gap-3">
        {Object.entries(eventCounts).map(([label, count]) => (
          <span
            key={label}
            className={`rounded-full px-4 py-1.5 text-sm font-medium ${
              label === "collision"
                ? "bg-red-500/20 text-red-400"
                : label === "sharp_brake"
                ? "bg-amber-500/20 text-amber-400"
                : "bg-slate-700 text-slate-300"
            }`}
          >
            {label}: {count}
          </span>
        ))}
      </div>

      <div className="mb-10 rounded-2xl border border-slate-800 bg-slate-900/50 p-4 sm:p-6">
        <h2 className="mb-4 text-lg font-semibold text-white">
          Acceleration magnitude (m/s²)
        </h2>
        <div className="h-[320px] w-full">
          <ResponsiveContainer width="100%" height="100%">
            <AreaChart data={chartData} margin={{ top: 10, right: 20, left: 0, bottom: 0 }}>
              <defs>
                <linearGradient id="accelGrad" x1="0" y1="0" x2="0" y2="1">
                  <stop offset="0%" stopColor="#10b981" stopOpacity={0.4} />
                  <stop offset="100%" stopColor="#10b981" stopOpacity={0} />
                </linearGradient>
              </defs>
              <CartesianGrid strokeDasharray="3 3" stroke="#1e2d4a" />
              <XAxis dataKey="time" stroke="#64748b" tick={{ fill: "#94a3b8", fontSize: 12 }} />
              <YAxis stroke="#64748b" tick={{ fill: "#94a3b8", fontSize: 12 }} domain={[0, "auto"]} />
              <Tooltip
                contentStyle={{
                  backgroundColor: "#131d33",
                  border: "1px solid #1e2d4a",
                  borderRadius: "12px",
                }}
                labelStyle={{ color: "#e2e8f0" }}
                formatter={(value: number) => [`${value} m/s²`, "Magnitude"]}
                labelFormatter={(label) => `Time: ${label}`}
              />
              <Area
                type="monotone"
                dataKey="magnitude"
                stroke="#10b981"
                strokeWidth={2}
                fill="url(#accelGrad)"
                name="Magnitude"
              />
            </AreaChart>
          </ResponsiveContainer>
        </div>
        {hasCollision && (
          <p className="mt-2 text-sm text-red-400">Spike indicates collision event.</p>
        )}
      </div>

      <div className="mb-10 rounded-2xl border border-slate-800 bg-slate-900/50 p-4 sm:p-6">
        <h2 className="mb-4 text-lg font-semibold text-white">Speed (km/h)</h2>
        <div className="h-[240px] w-full">
          <ResponsiveContainer width="100%" height="100%">
            <LineChart data={chartData} margin={{ top: 10, right: 20, left: 0, bottom: 0 }}>
              <CartesianGrid strokeDasharray="3 3" stroke="#1e2d4a" />
              <XAxis dataKey="time" stroke="#64748b" tick={{ fill: "#94a3b8", fontSize: 12 }} />
              <YAxis stroke="#64748b" tick={{ fill: "#94a3b8", fontSize: 12 }} />
              <Tooltip
                contentStyle={{
                  backgroundColor: "#131d33",
                  border: "1px solid #1e2d4a",
                  borderRadius: "12px",
                }}
                labelStyle={{ color: "#e2e8f0" }}
              />
              <Line type="monotone" dataKey="speed" stroke="#3b82f6" strokeWidth={2} dot={false} name="Speed (km/h)" />
            </LineChart>
          </ResponsiveContainer>
        </div>
      </div>

      <div className="rounded-2xl border border-slate-800 bg-slate-900/50 overflow-hidden">
        <h2 className="border-b border-slate-800 px-4 py-3 text-lg font-semibold text-white sm:px-6">
          Event log
        </h2>
        <div className="overflow-x-auto">
          <table className="w-full text-left text-sm">
            <thead>
              <tr className="border-b border-slate-800 bg-slate-900/80">
                <th className="px-4 py-3 font-medium text-slate-400 sm:px-6">Time</th>
                <th className="px-4 py-3 font-medium text-slate-400 sm:px-6">Accel (m/s²)</th>
                <th className="px-4 py-3 font-medium text-slate-400 sm:px-6">Speed</th>
                <th className="px-4 py-3 font-medium text-slate-400 sm:px-6">Event</th>
              </tr>
            </thead>
            <tbody>
              {busSensorData.map((r, i) => (
                <tr key={i} className="border-b border-slate-800/80 hover:bg-slate-800/50">
                  <td className="px-4 py-3 text-slate-300 sm:px-6">{r.timestamp.slice(11)}</td>
                  <td className="px-4 py-3 font-mono text-slate-300 sm:px-6">
                    {getAccelMagnitude(r).toFixed(2)}
                  </td>
                  <td className="px-4 py-3 text-slate-300 sm:px-6">{r.speedKmh} km/h</td>
                  <td className="px-4 py-3 sm:px-6">
                    <span
                      className={`inline-block rounded px-2 py-0.5 text-xs font-medium ${
                        r.eventLabel === "collision"
                          ? "bg-red-500/20 text-red-400"
                          : r.eventLabel === "sharp_brake"
                          ? "bg-amber-500/20 text-amber-400"
                          : "bg-slate-700 text-slate-400"
                      }`}
                    >
                      {r.eventLabel}
                    </span>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
