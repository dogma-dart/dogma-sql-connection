// Copyright (c) 2015, the Dogma Project Authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a zlib license that can be found in
// the LICENSE file.

/// Contains the [SqlSchema] class.
library dogma.sql_connection.src.sql_schema;

//---------------------------------------------------------------------
// Standard libraries
//---------------------------------------------------------------------

import 'dart:async';

//---------------------------------------------------------------------
// Imports
//---------------------------------------------------------------------

import 'package:dogma_sql_connection/sql_connection.dart';

import 'sql_table.dart';
import 'sql_column.dart';

//---------------------------------------------------------------------
// Library contents
//---------------------------------------------------------------------

/// Provides methods to query and modify the underlying database schema.
///
/// The [SqlSchema] provides the base functionality for interacting with a
/// database schema. It follows the ANSI standard and will function without
/// modification for compliant databases. For querying the table columns it
/// uses the information_schema specification. If the database vendor does not
/// follow these specifications then the [SqlSchema]'s methods can be
/// overriden.
class SqlSchema {
  //---------------------------------------------------------------------
  // Member variables
  //---------------------------------------------------------------------

  SqlConnection connection;

  final Map<String, SqlTable> _tables = new Map<String, SqlTable>();

  //---------------------------------------------------------------------
  // Construction
  //---------------------------------------------------------------------

  /// Creates an instance of the [SqlSchema] class from the given database [connection].
  ///
  /// Warning! Instances of [SqlSchema] should only be created by a
  /// [SqlConnection] instance.
  SqlSchema();

  /// Retrieves the
  Future<SqlTable> getTable(String name) async {
    var table = _tables[name];

    if (table == null) {
      var values = await findTableInDatabase(name);
      var columns = [];

      for (var value in values) {
        columns.add(new SqlColumn(value[0]));
      }

      table = new SqlTable(name, columns);

      _tables[table.name] = table;
    }

    return table;
  }

  Future<SqlTable> addTable(String table, List<SqlColumn> columns) async {
    // Verify that the table is not present in the database
    var value = await getTable(table);

    if (value != null) {

    }

    return value;
  }

  /// Clears all the data within the [table].
  ///
  /// Warning! This in not an operation that can be rolled back and all data
  /// will be lost.
  Future<SqlTable> clearTable(String table) async {
    // Verify that the table is present in the database
    var value = await getTable(table);

    if (value != null) {
      // Truncate the table data
      await clearTableInDatabase(table);
    }

    return value;
  }

  /// Removes the [table] from the schema.
  ///
  /// Returns the dropped [SqlTable] within the [Future].
  ///
  /// Warning! This in not an operation that can be rolled back and all data
  /// will be lost.
  Future<SqlTable> removeTable(String table) async {
    // Verify that the table is present in the database
    var value = await getTable(table);

    if (value != null) {
      // Drop the table from the database and schema
      await removeTableInDatabase(table);

      _tables.remove(table);
    }

    return value;
  }

  /// Modifies the [table] to contain the columns in [add] and drop the columns in [remove].
  ///
  /// Returns the modified [SqlTable] within the [Future].
  Future<SqlTable> modifyTable(String table, { List<SqlColumn> add, List<SqlColumn> remove}) async {
    // Verify that the table is present in the database
    var value = await getTable(table);

    if (value != null) {
      // Drop the table from the database and schema
      await removeTableInDatabase(table);

      _tables.remove(table);
    }

    return value;

  }

  //---------------------------------------------------------------------
  // Protected methods
  //---------------------------------------------------------------------

  /// Adds the [table] with the given [columns] to the database.
  ///
  /// This method interacts directly with the [SqlConnection] to perform the
  /// necessary statements to modify the schema.
  ///
  /// Internal use only! Non ANSI compliant databases should modify this method
  /// to provide vendor specific extensions.
  Future<dynamic> addTableInDatabase(String table, List<SqlColumn> columns) async {

  }

  /// Finds the [table] within the database and gets metadata on its columns.
  ///
  /// This method interacts directly with the [SqlConnection] to perform the
  /// necessary statements to modify the schema.
  ///
  /// Internal use only! Non ANSI compliant databases should modify this method
  /// to provide vendor specific extensions.
  Future<dynamic> findTableInDatabase(String table) async {
    var buffer = new StringBuffer();

    buffer
      ..writeln('SELECT column_name,data_type,column_default,is_nullable,character_maximum_length,numeric_precision')
      ..writeln('FROM information_schema.columns')
      ..writeln('WHERE table_name = \'$table\'')
      ..writeln('ORDER BY ordinal_position;');

    return connection.executeSql(buffer.toString());
  }

  Future<dynamic> clearTableInDatabase(String table) async {
    var statement = 'TRUNCATE TABLE $table';

    return connection.executeSql(table);
  }

  Future<dynamic> removeTableInDatabase(String table) async {
    var statement = 'DROP TABLE $table';

    return connection.executeSql(statement);
  }
}
