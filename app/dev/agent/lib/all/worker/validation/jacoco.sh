_jacoco_coverage() {
  local jacoco_xml_report=$(find . -type f -name jacoco.xml -print -quit)

  local overall_line_covered=$(xmllint --xpath 'string(//report/counter[@type="LINE"]/@covered)' $jacoco_xml_report)
  local overall_line_missed=$(xmllint --xpath 'string(//report/counter[@type="LINE"]/@missed)' $jacoco_xml_report)

  [ $overall_line_missed -eq 0 ]
}
