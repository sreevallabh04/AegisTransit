"use client";

import { passengerHealthData } from "@/lib/data";

export default function PassengersPage() {
  return (
    <div className="mx-auto max-w-7xl px-4 py-8 sm:px-6">
      <div className="mb-8">
        <h1 className="text-3xl font-bold tracking-tight text-white">
          Passengers
        </h1>
        <p className="mt-1 text-slate-400">
          Health readings — heart rate, SpO2, conditions
        </p>
      </div>

      {/* Summary cards */}
      <div className="mb-8 grid gap-4 sm:grid-cols-3">
        <div className="rounded-2xl border border-slate-800 bg-slate-900/50 p-5">
          <p className="text-sm font-medium text-slate-400">On board</p>
          <p className="mt-1 text-2xl font-bold text-white">
            {passengerHealthData.length}
          </p>
          <p className="mt-0.5 text-xs text-slate-500">passengers</p>
        </div>
        <div className="rounded-2xl border border-slate-800 bg-slate-900/50 p-5">
          <p className="text-sm font-medium text-slate-400">Avg heart rate</p>
          <p className="mt-1 text-2xl font-bold text-bus-400">
            {Math.round(
              passengerHealthData.reduce((s, p) => s + p.heartRateBpm, 0) /
                passengerHealthData.length
            )}{" "}
            bpm
          </p>
          <p className="mt-0.5 text-xs text-slate-500">last reading</p>
        </div>
        <div className="rounded-2xl border border-slate-800 bg-slate-900/50 p-5">
          <p className="text-sm font-medium text-slate-400">Avg SpO2</p>
          <p className="mt-1 text-2xl font-bold text-bus-400">
            {Math.round(
              passengerHealthData.reduce((s, p) => s + p.spo2Percent, 0) /
                passengerHealthData.length
            )}%
          </p>
          <p className="mt-0.5 text-xs text-slate-500">last reading</p>
        </div>
      </div>

      {/* Table */}
      <div className="rounded-2xl border border-slate-800 bg-slate-900/50 overflow-hidden">
        <h2 className="border-b border-slate-800 px-4 py-3 text-lg font-semibold text-white sm:px-6">
          Passenger list
        </h2>
        <div className="overflow-x-auto">
          <table className="w-full text-left text-sm">
            <thead>
              <tr className="border-b border-slate-800 bg-slate-900/80">
                <th className="px-4 py-3 font-medium text-slate-400 sm:px-6">Seat</th>
                <th className="px-4 py-3 font-medium text-slate-400 sm:px-6">Name</th>
                <th className="px-4 py-3 font-medium text-slate-400 sm:px-6">HR</th>
                <th className="px-4 py-3 font-medium text-slate-400 sm:px-6">SpO2</th>
                <th className="px-4 py-3 font-medium text-slate-400 sm:px-6">Temp</th>
                <th className="px-4 py-3 font-medium text-slate-400 sm:px-6">Condition</th>
                <th className="px-4 py-3 font-medium text-slate-400 sm:px-6">Route</th>
              </tr>
            </thead>
            <tbody>
              {passengerHealthData.map((p, i) => (
                <tr
                  key={i}
                  className="border-b border-slate-800/80 hover:bg-slate-800/50"
                >
                  <td className="px-4 py-3 font-medium text-white sm:px-6">
                    {p.seatNumber}
                  </td>
                  <td className="px-4 py-3 text-slate-300 sm:px-6">
                    {p.passengerName}
                  </td>
                  <td className="px-4 py-3 font-mono text-slate-300 sm:px-6">
                    {p.heartRateBpm} bpm
                  </td>
                  <td className="px-4 py-3 sm:px-6">
                    <span
                      className={
                        p.spo2Percent >= 96
                          ? "text-bus-400"
                          : p.spo2Percent >= 90
                          ? "text-amber-400"
                          : "text-red-400"
                      }
                    >
                      {p.spo2Percent}%
                    </span>
                  </td>
                  <td className="px-4 py-3 text-slate-300 sm:px-6">
                    {p.skinTempC}°C
                  </td>
                  <td className="px-4 py-3 text-slate-400 sm:px-6">
                    {p.existingCondition === "None" ? "—" : p.existingCondition}
                  </td>
                  <td className="px-4 py-3 text-slate-400 sm:px-6">
                    {p.startDest} → {p.endDest}
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
