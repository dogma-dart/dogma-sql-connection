// Copyright (c) 2015, the Dogma Project Authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a zlib license that can be found in
// the LICENSE file.

/// An implementation of a Dogma [Connection] that interfaces with a SQL database.
library dogma.sql_connection;

//---------------------------------------------------------------------
// Standard libraries
//---------------------------------------------------------------------

import 'dart:async';

//---------------------------------------------------------------------
// Imports
//---------------------------------------------------------------------

import 'package:dogma_connection/connection.dart';

import 'src/sql_schema.dart';
import 'src/sql_table.dart';
import 'src/sql_statement_builder.dart';

//---------------------------------------------------------------------
// Library contents
//---------------------------------------------------------------------

abstract class SqlConnection implements Connection {
  /// The database schema.
  final SqlSchema schema;
  /// Builds the SQL statements for querying the database.
  final SqlStatementBuilder statementBuilder;

  /// Creates a [SqlConnection]
  SqlConnection(this.schema, this.statementBuilder);

  //---------------------------------------------------------------------
  // Connection
  //---------------------------------------------------------------------

  @override
  Stream<dynamic> query(Query query) async* {
    // Get the metadata from the table to determine if a JOIN should happen
    var table = await schema.getTable(query.table) as SqlTable;

    // Get the columns
    var fields = query.fields;
    var columns = fields.isNotEmpty
        ? fields
        : table.columns.map((column) => column.name).toList();
    var columnCount = columns.length;

    // Execute the statement
    var values = executeSql(statementBuilder.query(query)).map((row) {
      var value = {};

      for (var i = 0; i < columnCount; ++i) {
        value[columns[i]] = row[i];
      }

      return value;
    });

    // Add the values to the stream
    yield* values;
  }

  @override
  Stream<dynamic> execute(Command command) async {
    return executeSql(statementBuilder.command(command));
  }

  //---------------------------------------------------------------------
  // Public methods
  //---------------------------------------------------------------------

  /// Executes the SQL [statement] on the database.
  Stream<dynamic> executeSql(String statement);
}
