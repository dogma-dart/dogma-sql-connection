// Copyright (c) 2015, the Dogma Project Authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a zlib license that can be found in
// the LICENSE file.

/// Contains the [SqlStatementBuilder] class.
library dogma_sql_connection.src.sql_statement_builder;

//---------------------------------------------------------------------
// Imports
//---------------------------------------------------------------------

import 'package:dogma_connection/command.dart';
import 'package:dogma_connection/expression.dart';
import 'package:dogma_connection/query.dart';

//---------------------------------------------------------------------
// Library contents
//---------------------------------------------------------------------

/// Generates ANSI standard SQL statements that can be run on a database.
///
/// The [SqlStatementBuilder] translates [Command] and [Query] instances into
/// the equivalent SQL statements. It also provides functionality outside of
/// those components, such as working with the underlying database tables.
///
/// The [SqlStatementBuilder] provides the base functionality for generating
/// SQL statements that can be run against a database. While SQL is an ANSI
/// standard individual database vendors have different variations for
/// functionality. Because of this the [SqlStatementBuilder]'s methods can be
/// overriden in these cases.
class SqlStatementBuilder {
  //---------------------------------------------------------------------
  // Query operations
  //---------------------------------------------------------------------

  /// Generates a SQL statement from the given [query].
  String query(Query query) {
    var buffer = new StringBuffer();

    /// Generate the fields
    var fields = query.fields;
    var fieldCount = fields.length;

    buffer.write('SELECT');

    if (fieldCount == 0) {
      buffer.write(' *');
    } else {
      buffer.write(' ${fields[0]}');

      for (var i = 1; i < fieldCount; ++i) {
        buffer.write(',${fields[i]}');
      }
    }

    // Generate the table
    buffer.write('\nFROM ${query.table}');

    // Generate the where clause
    var where = query.where;

    if (where != null) {
      buffer.write('\nWHERE ');
      _whereClause(buffer, query.where);
    }

    // Generate the order by clause
    var orderBy = query.orderBy;

    if (orderBy.isNotEmpty) {
      buffer.write('\nORDER BY $orderBy DESC');
    }

    // Generate the limit clause
    var limit = query.limit;

    if (limit != Query.noLimit) {
      buffer.write('\nLIMIT $limit');
    }

    // Generate the offset clause
    var offset = query.offset;

    if (offset != 0) {
      buffer.write('\nOFFSET $offset');
    }

    // Terminate the statement
    buffer.write(';');

    return buffer.toString();
  }

  //---------------------------------------------------------------------
  // Command operations
  //---------------------------------------------------------------------

  /// Generates a SQL statement from the given [command].
  String command(Command command) {
    var buffer = new StringBuffer();

    return buffer.toString();
  }

  //---------------------------------------------------------------------
  // Private methods
  //---------------------------------------------------------------------

  /// Generates the [where] clause for a SQL statement into the [buffer].
  void _whereClause(StringBuffer buffer, Expression where) {
    var type = where.nodeType;

    if (where is BinaryExpression) {
      buffer.write('(');
      _whereClause(buffer, where.left);

      var operator;

      switch (type) {
        case ExpressionType.and:
          operator = ' AND ';
          break;
        case ExpressionType.or:
          operator = ' OR ';
          break;
        case ExpressionType.equal:
          operator = '=';
          break;
        case ExpressionType.notEqual:
          operator = '<>';
          break;
        case ExpressionType.lessThan:
          operator = '<';
          break;
        case ExpressionType.lessThanOrEqual:
          operator = '<=';
          break;
        case ExpressionType.greaterThan:
          operator = '>';
          break;
        case ExpressionType.greaterThanOrEqual:
          operator = '>=';
          break;
        default:
          assert(false);
      }

      buffer.write(operator);

      _whereClause(buffer, where.right);
      buffer.write(')');
    } else if (where is ConstantExpression) {
      var constant = where.value;
      var wrap = constant is num ? '' : '\'';
      buffer.write('$wrap${constant.toString()}$wrap');
    } else if (where is ParameterExpression) {
      buffer.write(where.name);
    } else if (where is UnaryExpression) {
      buffer.write('NOT ');

      _whereClause(buffer, where.operand);
    }
  }
}
