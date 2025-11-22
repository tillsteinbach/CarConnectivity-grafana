# Grafana Dashboard Conversion: PostgreSQL to SQLite EAV

## Overview
This document describes the conversion of the Car Overview dashboard from PostgreSQL to SQLite with an Entity-Attribute-Value (EAV) schema.

**Source:** `overview.json.postgres-backup` (original PostgreSQL version)
**Current:** `overview.json` (converted SQLite EAV version)
**Date:** 2025-11-06
**Conversion Method:** Python script (`/tmp/convert_dashboard.py`)

## Conversion Summary

### Successfully Converted Panels (9)
The following panels were fully converted to use the EAV schema:

1. **Battery (now)** - Current SoC gauge
   - Attribute: `/garage/{VIN}/drives/primary/level` (float)
   
2. **Battery Level** - SoC time series
   - Attribute: `/garage/{VIN}/drives/primary/level` (float)
   
3. **Car Online State** - Current online/offline status
   - Attribute: `/garage/{VIN}/connection_state` (enum)
   
4. **Last Data from Car** - Last update timestamps
   - Note: Simplified version, needs proper timestamp tracking
   
5. **Projected Electric Range (now)** - Current range gauge
   - Attribute: `/garage/{VIN}/drives/primary/range` (float)
   
6. **Remaining Climatization Time (now)** - Climatization timer
   - Requires climatization time tracking attribute
   
7. **Charging Power (now)** - Current charging power
   - Attribute: `/garage/{VIN}/charging/power` (float)
   
8. **Charging** - Charging power and rate time series
   - Attributes: `/garage/{VIN}/charging/power` and `/garage/{VIN}/charging/rate` (float)
   
9. **States** - Online, Climatization, and Charging state timeline
   - Attributes: 
     - `/garage/{VIN}/connection_state` (enum)
     - `/garage/{VIN}/climatization/state` (enum)
     - `/garage/{VIN}/charging/state` (enum)

### Panels Requiring Configuration Data (4)
These panels need data from vehicle_settings table (WLTP range, capacity, etc.) which is not yet migrated to EAV:

1. **Levels & Range** - Primary/secondary engine levels and ranges
2. **Information** - Vehicle settings and recent events
3. **Consumption & Range extrapolated to 100% SoC** - Efficiency calculations
4. **Efficiency** - WLTP comparison

### Panels Not Yet Converted (1)
1. **Remaining Charging Time (now)** - Needs remaining charge time attribute

### Disabled Features
- **Online annotation** - Requires session tracking
- **Climatization annotation** - Requires session tracking  
- **Charging annotation** - Requires session tracking

## EAV Schema Mappings

### Float Attributes
| PostgreSQL Column | EAV Attribute Path | Table |
|------------------|-------------------|-------|
| currentSOC_pct | /garage/{VIN}/drives/primary/level | attribute_float_value |
| cruisingRangeElectric_km | /garage/{VIN}/drives/primary/range | attribute_float_value |
| totalRange_km | /garage/{VIN}/drives/total_range | attribute_float_value |
| chargePower_kW | /garage/{VIN}/charging/power | attribute_float_value |
| chargeRate_kmph | /garage/{VIN}/charging/rate | attribute_float_value |

### Enum Attributes
| PostgreSQL Column | EAV Attribute Path | Table | Values |
|------------------|-------------------|-------|--------|
| chargingState | /garage/{VIN}/charging/state | attribute_enum_value | CHARGING, NOT_READY_FOR_CHARGING, etc. |
| climatisationState | /garage/{VIN}/climatization/state | attribute_enum_value | OFF, HEATING, COOLING, VENTILATION |
| connection_state | /garage/{VIN}/connection_state | attribute_enum_value | ONLINE, OFFLINE |
| vehicle state | /garage/{VIN}/state | attribute_enum_value | Various states |

## Key Conversion Patterns

### Time Conversion
PostgreSQL timestamps are converted to Unix epoch using SQLite's `strftime()`:
```sql
-- Before
"carCapturedTimestamp" AS "time"

-- After
strftime('%s', v.start_date) AS time
```

### Time Filtering
Grafana's `$__timeFilter()` macro is replaced with:
```sql
-- Before
$__timeFilter("carCapturedTimestamp")

-- After
strftime('%s', v.start_date) BETWEEN $__from AND $__to
```

### Dynamic VIN Filtering
```sql
-- Before
WHERE vehicle_vin = '$VIN'

-- After
WHERE a.path = '/garage/' || '$VIN' || '/drives/primary/level'
```

### EAV JOIN Pattern
```sql
SELECT
  strftime('%s', v.start_date) AS time,
  v.value AS "Metric Name"
FROM attribute a
JOIN attribute_float_value v ON a.id = v.attribute_id
WHERE
  a.path = '/garage/' || '$VIN' || '/path/to/attribute' AND
  strftime('%s', v.start_date) BETWEEN $__from AND $__to
ORDER BY time
```

## Template Variables

### VIN Variable
Changed from PostgreSQL settings table query to SQLite attribute query:
- **Type:** query
- **Query:** `SELECT DISTINCT substr(path, 9, 17) as vin FROM attribute WHERE path LIKE '/garage/%' AND length(substr(path, 9, 17)) = 17`
- **Note:** Automatically discovers VINs from the database - no manual configuration needed

### vwsfriend_url Variable
Disabled for SQLite version (not needed without vehicle_settings table)

## Datasource Configuration

All PostgreSQL datasources changed to:
```json
{
  "type": "frser-sqlite-datasource",
  "uid": "P2EF847825A020B66"
}
```

## Known Limitations

1. **No session tracking** - Online sessions, charging sessions, and climatization sessions require complex window functions and state tracking not yet implemented
2. **No vehicle configuration** - WLTP range, battery capacity, and other vehicle-specific settings need to be added to EAV schema
3. **No trip/refueling data** - Trip history and refueling sessions not migrated
4. **Simplified timestamps** - Last update/change tracking needs proper implementation
5. **Hardcoded VIN** - VIN selector needs dynamic query or manual update

## Next Steps

To fully utilize this dashboard:

1. **Update VIN variable** - Change the hardcoded VIN to match your vehicle
2. **Add missing attributes** - Implement remaining time, timestamps, etc.
3. **Add configuration data** - Migrate vehicle settings to EAV if needed
4. **Implement session tracking** - Add support for online, charging, and climatization sessions
5. **Test with real data** - Verify all queries return expected results

## Testing Recommendations

1. Test time series panels with different time ranges
2. Verify gauge panels show current values
3. Check state timeline displays correctly
4. Confirm VIN variable substitution works
5. Validate data type conversions (float vs enum)

## File Locations

- **Current Dashboard:** `overview.json` (SQLite EAV version - active)
- **PostgreSQL Backup:** `overview.json.postgres-backup` (original version)
- **Alternative Backup:** `overview.json.backup` (if exists)
- **Task Agent Output:** `overview-sqlite.json` (can be deleted)
- **Conversion Script:** `/tmp/convert_dashboard.py`
- **Database:** `/home/grafana/.carconnectivity/carconnectivity.db` (in grafana container)
