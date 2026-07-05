_jacoco_coverage() {
  local jacoco_xml_report
  jacoco_xml_report=$(find . -type f -name jacoco.xml -print -quit)

  [ -z "$jacoco_xml_report" ] && {
    log_warn "no jacoco.xml found — skipping coverage check"
    return 0
  }

  local overall_line_covered
  local overall_line_missed
  overall_line_covered=$(xmllint --xpath 'string(//report/counter[@type="LINE"]/@covered)' "$jacoco_xml_report")
  overall_line_missed=$(xmllint --xpath 'string(//report/counter[@type="LINE"]/@missed)' "$jacoco_xml_report")

  [ -z "$overall_line_covered" ] || [ -z "$overall_line_missed" ] && {
    log_warn "could not parse LINE counters from $jacoco_xml_report"
    return 1
  }

  local total=$((overall_line_covered + overall_line_missed))
  [ "$total" -eq 0 ] && {
    log_warn "jacoco reports zero executable lines — skipping coverage check"
    return 0
  }

  local threshold="${agent_jacoco_threshold:-0}"
  local coverage_pct=$(((overall_line_covered * 100) / total))

  if [ "$coverage_pct" -lt "$threshold" ]; then
    log_warn "jacoco coverage ${coverage_pct}% is below threshold ${threshold}%"
    return 1
  fi

  log_detail "jacoco coverage ${coverage_pct}% meets threshold ${threshold}%"
  return 0
}
