# Literature Papers Overview: Contributions and Limitations

This document summarizes what each cited paper contributes and its limitations, as relevant to the Smart Bus Accident & Passenger Health Monitoring System.

---

## 1. Bus Management & Road Accident Prevention System for Smart Cities  
**IEEE Xplore 9392747**

**What it has:** A system for bus fleet management and road accident prevention tailored to smart city infrastructure. It integrates monitoring and alerting to improve bus operations and road safety, leveraging sensor networks and real-time data for accident prevention and fleet coordination.

**Limitations:** Focuses on fleet and road-level monitoring rather than passenger-level physiological data. Does not address individual passenger health or wearable integration. Smart city deployment assumes existing urban infrastructure; applicability to rural or low-resource settings is unclear.

---

## 2. A Comprehensive Study on IoT Based Accident Detection Systems for Smart Vehicles  
**IEEE Xplore 9133106**

**What it has:** A survey and architectural analysis of IoT-based accident detection systems for smart vehicles. Covers sensors (IMU, accelerometers), communication paradigms (BLE, cellular, Wi-Fi), and system architectures suitable for vehicle-mounted detection units.

**Limitations:** A study/survey rather than an implemented system; no empirical validation. Does not cover passenger health monitoring or post-accident triage. May not address bus-specific scenarios (e.g., multiple passengers, public transport constraints).

---

## 3. IoT based Smart Accident Detection and Emergency Response System for Vehicles  
**IEEE Xplore 10846091**

**What it has:** An IoT system for real-time accident detection and automated emergency response in vehicles. Emphasizes fast detection, GPS-based location reporting, and automated notification to emergency services.

**Limitations:** Vehicle-centric; no passenger-wise health or physiological monitoring. Response prioritization is likely based on vehicle damage and location, not on individual passenger condition. Does not integrate wearables or vital signs.

---

## 4. RFID-Based Automated Bus Door System with Emergency Alert and Seat Monitoring  
**IEEE Xplore 10862724**

**What it has:** An RFID-based automated bus door system with emergency alert and seat-level monitoring. Links passenger presence and seat occupancy to safety and evacuation support, providing seat-wise awareness during emergencies.

**Limitations:** RFID provides seat presence/occupancy only, not physiological data (heart rate, stress, injury severity). Does not infer passenger condition from vitals. May require RFID tags or cards, which adds deployment and user-compliance overhead.

---

## 5. Smart Wearable Device to Prevent Accidents Caused by Medical Emergencies  
**IEEE Xplore 10084266**

**What it has:** A smart wearable that uses physiological signals (e.g., heart rate, HRV, activity) to detect medical emergencies and trigger alerts or countermeasures. Aims to prevent accidents caused by driver or occupant medical events (e.g., cardiac events, syncope).

**Limitations:** Focused on preventing accidents from medical emergencies rather than post-accident triage. May not address multi-passenger scenarios or bus-specific layouts. Accuracy and false-alarm rates in real driving conditions may vary.

---

## 6. IoT Enabled Wearable Technology Jacket for Tracking Patient Health and Safety  
**IEEE Xplore 10391431**

**What it has:** An IoT-enabled wearable jacket that tracks patient health and safety. Streams vital data (e.g., heart rate, temperature) to gateways for remote monitoring and alerting.

**Limitations:** Jacket form factor may be less acceptable than wrist wearables for everyday public transport use. Target audience appears to be patients rather than general passengers. Scalability to many passengers on a bus may not be addressed.

---

## 7. Heart Rate Variability Based Stress Assessment: A Case Study for Wearable Platforms  
**IEEE Xplore 9302404**

**What it has:** A case study on using heart rate variability (HRV) for stress assessment on wearable platforms. Validates HRV-derived stress indicators and discusses implementation considerations for wearables.

**Limitations:** Single case study; generalizability to diverse populations and environments is unclear. Does not directly address accident or emergency contexts. May require calibration or baseline data per user.

---

## 8. Accurate Stress Detection for Developers: Leveraging Low-Cost IoT Devices (ESP32 and MAX30102) to Analyze Heart Rate Variability  
**IEEE Xplore 10417345**

**What it has:** Uses low-cost IoT hardware (ESP32 microcontroller and MAX30102 optical sensor) to capture and analyze HRV for stress detection. Demonstrates feasibility of inexpensive, embedded stress sensing.

**Limitations:** Target population is developers in office settings, not bus passengers in dynamic, noisy environments. Motion artifacts and environmental factors in transit may degrade accuracy. Does not address post-accident triage or emergency response.

---

## 9. Crash Detection Using IMU Sensors  
**IEEE Xplore 7968631**

**What it has:** A method for crash detection using inertial measurement unit (IMU) sensors. Uses accelerometer and gyroscope data to detect impacts, rollovers, and sudden deceleration, forming a foundation for vehicle-level crash detection.

**Limitations:** Vehicle-level only; no passenger health or severity inference. May require tuning for different vehicle types and crash scenarios. Class imbalance (crashes are rare) can affect model performance; robustness across crash severities may vary.

---

## 10. Advanced Collision and Obstruction Detection and Prevention using ESP-32 & Deep Learning  
**IEEE Xplore 10405347**

**What it has:** Combines ESP32 microcontroller with deep learning for advanced collision and obstruction detection and prevention. Shows that low-cost embedded platforms can support both classical and learning-based detection.

**Limitations:** Focuses on collision/obstruction prevention rather than post-crash passenger assessment. Deep learning models may need substantial training data and computational resources. Real-time inference on ESP32 under resource constraints may limit model complexity.

---

## 11. Edge Intelligence for Mission Cognitive Wireless Emergency Networks  
**IEEE Xplore 9083671**

**What it has:** Presents edge intelligence for mission-critical wireless emergency networks. Highlights the role of edge processing in latency-sensitive emergency scenarios and discusses cognitive radio and network adaptation.

**Limitations:** Emphasizes network and radio layer; less detail on application-level sensor fusion or health data. May assume military or specialized emergency networks rather than public transport. Hardware and deployment specifics for bus environments may not be addressed.

---

## 12. A Portable and Elastic Edge Computing Network for Disaster First Responders  
**IEEE Xplore 10936663**

**What it has:** Describes a portable, elastic edge computing network for disaster first responders. Focuses on deployable edge infrastructure that can operate in disrupted or resource-constrained environments.

**Limitations:** Oriented toward disaster scenarios (earthquakes, floods) rather than routine bus accidents. Deployment model may differ from fixed bus routes and urban infrastructure. Does not address passenger health or wearable integration.

---

## 13. Developing Real-Time IoT-Based Public Safety Alert and Emergency Response Systems  
**H. Zhang, R. Zhang, J. Sun — Scientific Reports, 2025**

**What it has:** A comprehensive real-time IoT public safety system with distributed sensors (gas, flame, vibration, biometric), edge nodes (Raspberry Pi, ESP32), and cloud (AWS IoT, Firebase). Achieves alert latency under 450 ms, detection accuracy >95%, scalability to 12,000+ devices, and 99.1% alert reliability. Supports fire, traffic accident, gas leak, and medical distress scenarios. Uses MQTT over TLS with LoRa fallback.

**Limitations:** Multi-scenario (fire, gas, traffic, medical) design may not optimize for bus-specific passenger triage. Biometric sensors may not provide passenger-wise severity classification. Reliance on cloud and connectivity; performance in offline or low-connectivity bus environments may degrade.

---

## 14. Design of Automobile Intelligence Control Platform Based on Bluetooth Low Energy  
**IEEE Xplore 7848552**

**What it has:** An automobile intelligence control platform using Bluetooth Low Energy (BLE). Demonstrates BLE for in-vehicle connectivity and control, establishing feasibility of BLE in automotive applications.

**Limitations:** Focuses on control (e.g., infotainment, locks) rather than health or safety sensing. Older (2016) work; BLE standards and best practices have evolved. May not address high-density passenger scenarios (many wearables in one bus).

---

## 15. Bluetooth Low Energy Based Communication Framework for Intra Vehicle Wireless Sensor Networks  
**IEEE Xplore 8261007**

**What it has:** A BLE-based communication framework for intra-vehicle wireless sensor networks. Enables low-power, in-vehicle sensor connectivity for monitoring and diagnostics.

**Limitations:** Vehicle-centric (engine, chassis, diagnostics) rather than passenger health. May not handle many concurrent BLE connections (e.g., dozens of passengers with wearables). Interference and coexistence with other in-vehicle radios not fully addressed.

---

## 16. Intra-Vehicular Communication Protocol for IoT Enabled Vehicle Health Monitoring System: Challenges, Issues, and Solutions  
**IEEE Xplore 10587237**

**What it has:** Discusses intra-vehicular communication protocols for IoT-enabled vehicle health monitoring. Covers challenges, issues, and proposed solutions for reliable, low-latency in-vehicle sensor data exchange.

**Limitations:** "Vehicle health" refers to mechanical/electrical systems, not passenger health. Protocols may need adaptation for passenger wearables and multi-tenant data (privacy, access control). Bus-specific topology (many seats, gateway placement) may require additional design.

---

## 17. Crisis Management in the Era of the IoT, Edge Computing, and LLMs  
**IEEE Xplore 10710254**

**What it has:** Positions large language models (LLMs) as a decision-support layer over IoT and edge data for crisis management. Discusses how LLMs can interpret sensor streams, generate summaries, and support emergency coordination.

**Limitations:** Conceptual/framework paper; implementation details and validation may be limited. LLM latency and cost in real-time crisis scenarios may be a concern. Privacy and data handling for sensitive health data need careful consideration. May not specifically address bus or public transport contexts.

---

## 18. Intelligent Urban Emergency Response: Integrating Large Language Models, Multi-Objective Optimization, and Reinforcement Learning  
**IEEE Xplore 2024**

**What it has:** An intelligent urban emergency response system that integrates LLMs with multi-objective optimization and reinforcement learning for improved decision-making in emergencies.

**Limitations:** Urban-wide optimization may not provide passenger-level triage guidance. RL and optimization assume training data and simulation; transfer to real bus accidents may require validation. Complexity may hinder deployment in resource-constrained settings. Does not explicitly cover wearable or passenger health data integration.

---

## Summary Table

| # | Paper Theme | Key Contribution | Main Limitation |
|---|-------------|------------------|-----------------|
| 1 | Bus safety | Fleet & road accident prevention | No passenger health |
| 2 | IoT accident systems | Survey of architectures | No implementation; no health |
| 3 | Accident + response | Real-time detection, auto-notify | Vehicle-centric; no vitals |
| 4 | RFID bus doors | Seat monitoring, emergency alert | No physiological data |
| 5 | Wearable medical | Prevent accidents from medical events | Pre-accident focus; single user |
| 6 | Wearable jacket | Health tracking, gateway streaming | Jacket form; patient focus |
| 7 | HRV stress | HRV-based stress on wearables | Case study; not emergency |
| 8 | ESP32 stress | Low-cost HRV stress detection | Office setting; not transit |
| 9 | IMU crash | Crash detection via IMU | Vehicle-level only |
| 10 | ESP32 + DL | Collision detection with deep learning | Prevention focus; compute limits |
| 11 | Edge emergency | Edge intelligence for emergency nets | Network focus; not health |
| 12 | Portable edge | Edge for disaster responders | Disaster focus; not buses |
| 13 | Real-time IoT safety | Full IoT safety system (450 ms, 95%) | Multi-scenario; cloud-dependent |
| 14 | BLE automobile | BLE for auto control | Control focus; older work |
| 15 | BLE intra-vehicle | BLE framework for in-vehicle sensors | Vehicle diagnostics; not health |
| 16 | Intra-vehicle protocol | IoT vehicle health protocols | Mechanical health; not passenger |
| 17 | Crisis + LLM | LLM for crisis decision support | Conceptual; bus context unclear |
| 18 | Urban emergency + LLM | LLM + optimization + RL | Urban-wide; not passenger triage |
