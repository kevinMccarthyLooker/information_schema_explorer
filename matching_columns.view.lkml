include: "information_schema__columns.view"

view: matching_columns {
  extends: [information_schema__columns]

  dimension: same_field {
    group_label: " Match types"
    type: yesno
    sql: ${matching_columns.table_name__column_name}=${possible_keys.table_name__column_name} ;;
  }

  dimension: direct_id_match {
    group_label: " match types"
    description: "original column, with '_id' removed, matches exactly to the target table table name"
    type: yesno
    sql:
    (
    ${possible_keys.table_name} =replace(${column_name},'_id','')
    or
    replace(${possible_keys.table_name},'s','') =replace(${column_name},'_id','')
    )
    and ${possible_keys.column_name}='id'
    ;;
  }

  dimension: column_name_match {
    group_label: " Match types"
    type: yesno
    sql: ${column_name}=${possible_keys.column_name} ;;
#     sql: ${column_name} like '%'||replace(${possible_keys.column_name},'_id','')||'%' ;;
  }

#   dimension: match_to_table_name {
#     group_label: " Match types"
#     type: yesno
#     sql: ${table_name} like '%'||replace(${possible_keys.column_name},'_id','')||'%' ;;
#   }

  dimension: match_to_table_name2 {
    group_label: " Match types"
    type: yesno
    sql:
    ${possible_keys.table_name} like '%'||replace(${column_name},'_id','')||'%' ;;
  }



  dimension: match_type {
    group_label: " match types"
    case: {
      when: {sql:${same_field};; label:"same_field"}
      when: {sql:${direct_id_match};; label:"direct_id_match"}
      when: {sql:${column_name_match};; label:"column_name_match"}
#       when: {sql:${match_to_table_name};; label:"match_to_table_name"}
      else: "No Match Found"
    }
  }

  measure: list_tables {
    type: list
    list_field: table_name
    sql: ${table_name} ;;
  }


}
