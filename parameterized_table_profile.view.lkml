view: parameterized_table_profile {
  derived_table: {
    sql:select count(*) as row_count from {% parameter table_name_input_parameter %};;
  }

  parameter: table_name_input_parameter {
    type: unquoted
  }

  dimension: row_count {type:number hidden:yes}
  measure: total_rows {type:sum sql:${row_count};;}

}
