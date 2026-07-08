# Panel Care AI Development Guide

## Project Identity

Project Name:
Panel Care

Type:
IoT-Based Solar Panel Cooling & Cleaning System

Status:
Final Year Project (Production-Oriented)

Technology Stack:
* Flutter
* Firebase
* Node.js
* MQTT
* ESP32
* Material 3

---

# Mission

Your primary goal is to help build this software as a professional software engineer.

Before making any changes:
* Understand the entire repository.
* Analyze dependencies.
* Explain your understanding.
* Create an implementation plan.
* Only then modify the code.

Never start coding immediately.

---

# System Overview

This project consists of four integrated systems.

ESP32 Firmware
↓
MQTT Broker
↓
Node.js Backend
↓
Firebase
↓
Flutter Mobile Application

Flutter must NEVER communicate directly with ESP32.
All communication flows through Backend and Firebase.

---

# Responsibilities

## Flutter
Responsible for:
* Authentication
* Dashboard
* Monitoring
* Cooling Control
* Cleaning Control
* Schedule
* Notifications
* History
* Settings

Flutter should only consume data.
Business logic belongs outside the UI.

---

## Backend
Responsible for:
* MQTT Subscription
* Device Validation
* Data Processing
* Firebase Synchronization
* Authentication
* REST API
* Notification Service
* Logging

Backend is the central business layer.

---

## ESP32
Responsible for:
* Reading Sensors
* Executing Commands
* Decision Tree
* Publishing MQTT Messages

Never move embedded logic into Flutter.

---

## Firebase
Responsible for:
* Authentication
* Realtime Database
* Cloud Messaging

Firebase is the synchronization layer.

---

# Hardware

Controller:
ESP32

Sensors:
* DS18B20
* GP2Y1010
* INA219
* RTC DS3231

Actuators:
* Cooling Pump
* Cleaning Pump
* Power Window Motor
* Peltier
* Fan

---

# Data Flow

Sensors
↓
ESP32
↓
MQTT
↓
Node.js
↓
Firebase
↓
Flutter
↓
User

Commands travel in reverse.

---

# Coding Standards

Always follow:
* SOLID
* DRY
* Clean Architecture
* Feature First Architecture
* Single Responsibility Principle

Never duplicate logic.
Never hardcode configuration.
Use reusable widgets.
Keep files small.

---

# UI Rules

Preserve existing UI.
Do not redesign screens unless explicitly requested.
Maintain:
* colors
* typography
* spacing
* border radius
* shadows
* animations

Never change UI structure without approval.

---

# Before Every Task

Always answer:
1. What files will be modified?
2. Why are they modified?
3. What impact will this have?
4. Are there any risks?
5. Is there a better solution?

Only after answering these questions may you modify the code.

---

# When Analyzing the Repository

Identify:
* Architecture
* Folder Structure
* Feature Flow
* Navigation
* State Management
* Firebase Integration
* MQTT Integration
* ESP32 Communication
* API Layer
* Repository Layer
* Mock Data
* Missing Features
* Technical Debt
* Security Issues
* Performance Issues

---

# Development Order

Always work in this sequence.

Phase 1: Repository Analysis
↓
Phase 2: Architecture Review
↓
Phase 3: Firebase Integration
↓
Phase 4: Authentication
↓
Phase 5: Realtime Database
↓
Phase 6: Backend API
↓
Phase 7: MQTT Integration
↓
Phase 8: ESP32 Integration
↓
Phase 9: Decision Tree
↓
Phase 10: Notification
↓
Phase 11: Testing
↓
Phase 12: Optimization

Never skip phases.

---

# Rules

Never delete existing functionality.
Never introduce breaking changes.
Never rename files unnecessarily.
Always preserve project consistency.
Always explain changes before applying them.
If requirements are unclear, ask before modifying.
Prefer maintainability over speed.
Think like a Senior Software Architect, not a code generator.
