import os
import json
import glob
import re

CONTENT_DIR = "src/iris/story/content"
INCIDENT_DIR = "src/iris/story/incidents"
MANIFEST_PATH = "src/iris/story/incidents/registry_manifest.json"
REPORT_PATH = "CONTENT_PIPELINE_REPORT.md"
ASSETS_DIR = "assets"

def log_error(errors, msg):
    print(f"[ERROR] {msg}")
    errors.append(msg)

def log_warn(warnings, msg):
    print(f"[WARN]  {msg}")
    warnings.append(msg)

def check_asset_exists(asset_path):
    if asset_path.startswith("res://"):
        local_path = asset_path.replace("res://", "")
        return os.path.exists(local_path)
    return False

def validate_content():
    errors = []
    warnings = []
    
    moment_files = glob.glob(os.path.join(CONTENT_DIR, "moment_*.json"))
    incident_files = glob.glob(os.path.join(INCIDENT_DIR, "incident_*.json"))
    
    # Ignore templates if they exist in those dirs
    moment_files = [f for f in moment_files if "template" not in f.lower()]
    incident_files = [f for f in incident_files if "template" not in f.lower()]
    
    loaded_moments = {}
    loaded_incidents = {}
    chapters = set()
    
    # 1. Validate Witness Moments
    for mf in moment_files:
        try:
            with open(mf, "r") as f:
                data = json.load(f)
                
            m_id = data.get("moment_id")
            if not m_id:
                log_error(errors, f"Missing moment_id in {mf}")
                continue
            
            if m_id in loaded_moments:
                log_error(errors, f"Duplicate moment_id found: {m_id} in {mf}")
            
            loaded_moments[m_id] = data
            chapters.add(data.get("chapter_id", "unknown"))
            
            # Check assets
            env = data.get("environment", {})
            for key in ["background_image", "action_image", "reveal_image"]:
                asset = env.get(key, "")
                if asset and not check_asset_exists(asset):
                    log_error(errors, f"Missing asset referenced in {m_id}: {asset}")
                    
        except json.JSONDecodeError:
            log_error(errors, f"Invalid JSON format in {mf}")
            
    # 2. Validate Incidents
    for inf in incident_files:
        try:
            with open(inf, "r") as f:
                data = json.load(f)
                
            inc_id = data.get("incident_id")
            if not inc_id:
                log_error(errors, f"Missing incident_id in {inf}")
                continue
                
            if inc_id in loaded_incidents:
                log_error(errors, f"Duplicate incident_id found: {inc_id} in {inf}")
                
            loaded_incidents[inc_id] = {
                "file": inf,
                "data": data
            }
            
            # Check moment mappings
            cases = data.get("memory_cases", [])
            if not cases:
                log_error(errors, f"No memory cases defined in incident {inc_id}")
                
            for case in cases:
                for wm_id in case.get("witness_moment_ids", []):
                    if wm_id not in loaded_moments:
                        log_error(errors, f"Incident {inc_id} references unknown Witness Moment: {wm_id}")
                        
        except json.JSONDecodeError:
            log_error(errors, f"Invalid JSON format in {inf}")
            
    # 3. Generate Registry Manifest
    # Sort incidents alphanumerically by filename (or ID) to ensure deterministic load order
    sorted_incidents = sorted(loaded_incidents.values(), key=lambda x: x["file"])
    
    registry = {
        "manifest_version": "1.0",
        "registry_schema_version": 1,
        "incidents": []
    }
    
    for inc in sorted_incidents:
        # Convert local path to res://
        res_path = "res://" + inc["file"].replace("\\", "/")
        registry["incidents"].append(res_path)
        
    try:
        with open(MANIFEST_PATH, "w") as f:
            json.dump(registry, f, indent=2)
        print(f"[INFO] Generated registry manifest with {len(registry['incidents'])} incidents.")
    except Exception as e:
        log_error(errors, f"Failed to write registry manifest: {str(e)}")

    # 4. Generate Report
    status = "PASS" if len(errors) == 0 else "FAIL"
    runtime_compat = "PASS" if len(errors) == 0 else "FAIL"
    
    report_content = f"""# CONTENT PIPELINE REPORT

**Date Generated:** Auto-generated via Content Tooling v1.0
**Overall Validation Status:** {status}
**Runtime Compatibility:** {runtime_compat}

## Content Metrics
* **Total Chapters:** {len(chapters)}
* **Total Witness Moments:** {len(loaded_moments)}
* **Total Incidents:** {len(loaded_incidents)}

## Validation Findings

### Errors ({len(errors)})
"""
    if errors:
        for e in errors:
            report_content += f"- ❌ {e}\n"
    else:
        report_content += "- None. All checks passed.\n"
        
    report_content += f"\n### Warnings ({len(warnings)})\n"
    if warnings:
        for w in warnings:
            report_content += f"- ⚠️ {w}\n"
    else:
        report_content += "- None.\n"

    try:
        with open(REPORT_PATH, "w") as f:
            f.write(report_content)
        print(f"[INFO] Generated content report at {REPORT_PATH}")
    except Exception as e:
        print(f"[ERROR] Failed to write report: {str(e)}")

if __name__ == "__main__":
    print("==================================================")
    print(" WITNESS CONTENT PIPELINE TOOLING v1.0")
    print("==================================================")
    validate_content()
    print("==================================================")
