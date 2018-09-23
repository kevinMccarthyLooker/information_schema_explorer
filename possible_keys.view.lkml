include: "information_schema__columns.view.lkml"
view: possible_keys {
  extends: [information_schema__columns]

  dimension: has_id {
    group_label: " Classifications"
    type: yesno
    sql: ${column_name} like '%_id' ;;
  }

  dimension: is_simple_id {
    group_label: " Classifications"
    type: yesno
    sql: ${column_name} = 'id'  ;;
  }

  measure: has_id_count {
    type: count
    filters: {
      field: has_id
      value: "Yes"
    }
  }
}
