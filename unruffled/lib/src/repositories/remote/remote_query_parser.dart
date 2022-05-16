part of unruffled;

mixin _RemoteQueryParser<R extends DataModel<R>> on _RemoteRepository<R> {
  @override
  Map<String, dynamic> parseQuery({required QueryBuilder<R> queryBuilder}) {
    return parseOperation(queryBuilder.filterGroup);
  }

  @override
  Map<String, dynamic> parseOperation(FilterOperation<R> operation) {
    Map<String, dynamic> map = {};
    if (operation is FilterGroup<R>) {
      switch (operation.type) {
        case FilterGroupType.and:
          map.addAll(parseAndCondition(operation.filters));
          break;
        case FilterGroupType.or:
          map.addAll(parseOrCondition(operation.filters));
          break;
      }
    } else if (operation is FilterCondition<R>) {
      switch (operation.type) {
        case ConditionType.equal:
          map.addAll(parseEqual(operation));
          break;
        case ConditionType.notEqual:
          map.addAll(parseNotEqual(operation));
          break;
        case ConditionType.gt:
          map.addAll(parseGreaterThan(operation));
          break;
        case ConditionType.lt:
          map.addAll(parseLessThan(operation));
          break;
        case ConditionType.inRange:
          map.addAll(parseInValues(operation));
          break;
      }
    }
    return map;
  }

  @override
  Map<String, dynamic> parseEqual(FilterCondition<R> condition) => {};

  @override
  Map<String, dynamic> parseNotEqual(FilterCondition<R> condition) => {};

  @override
  Map<String, dynamic> parseGreaterThan(FilterCondition<R> condition) => {};

  @override
  Map<String, dynamic> parseLessThan(FilterCondition<R> condition) => {};

  @override
  Map<String, dynamic> parseInValues(FilterCondition<R> condition) => {};

  @override
  Map<String, dynamic> parseOrCondition(List<FilterOperation<R>> operations) =>
      {};

  @override
  Map<String, dynamic> parseAndCondition(List<FilterOperation<R>> operations) =>
      {};
}
