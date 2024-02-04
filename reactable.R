library(reactable)
reactable(iris)


## columns definitions
reactable(
  iris[1:5,],
  columns = list(
    Sepal.Length = colDef(name = "Sepal Length"),
    Sepal.Width = colDef(name = "Sepal Width"),
    Petal.Length = colDef(name = "Petal Length"),
    Petal.Width = colDef(name = "Petal Width")
  )
)

reactable(
  iris[1:5, ],
  defaultColDef = colDef(
    header = function(value) gsub(".", " ", value, fixed = TRUE),
    cell = function(value) format(value, nsmall = 1),
    align = "center",
    minWidth = 70,
    headerStyle = list(background = "#f7f7f8")
  ),
  columns = list(
    Species = colDef(minWidth = 140)  # overrides the default
  ),
  bordered = TRUE,
  highlight = TRUE
)

gsub(":", ";", "Raes:Remmurd", fixed = TRUE) # substitution of a value
format(1.56, nsmall = 5) # decimal places

### Sorting
reactable(iris[48:52, ], defaultSorted = c("Species", "Petal.Length"))

### default sorted with the sort order specified
reactable(iris[48:52, ], 
          defaultSorted = list(Species = "asc", Petal.Length = "desc"))
## the default sort order is ascending

### defaultSortOrder
reactable(
  iris[48:52, ],
  defaultSortOrder = "desc",
  columns = list(
    Species = colDef(defaultSortOrder = "asc")
  ),
  defaultSorted = c("Species", "Petal.Length")
)

### to sort missing values last
reactable(
  data.frame(
    n = c(1, 2, 3, -Inf, Inf),
    x = c(2, 3, 1, NA, NaN),
    y = c("aa", "cc", "bb", NA, NA)
  ),
  defaultColDef = colDef(sortNALast = TRUE),
  defaultSorted = "x"
)


## No sorting and two columns that are sortable
reactable(
  iris[1:5, ],
  sortable = FALSE,
  showSortable = TRUE,
  columns = list(
    Petal.Width = colDef(sortable = TRUE),
    Petal.Length = colDef(sortable = TRUE)
  )
)


### Filtering in reactable
data <- MASS::Cars93[1:20, c("Manufacturer", "Model", "Type", "AirBags", "Price")]

reactable(data, filterable = TRUE, minRows = 10)

# To set specific columns as filterable or not
reactable(
  data,
  filterable = TRUE,
  columns = list(
    Price = colDef(filterable = FALSE)
  ),
  defaultPageSize = 5
)

## Custom filtering
data <- MASS::Cars93[, c("Manufacturer", "Model", "Type", "Price")]

reactable(
  data,
  columns = list(
    Manufacturer = colDef(
      filterable = TRUE,
      # Filter by case-sensitive text match
      filterMethod = JS("function(rows, columnId, filterValue) {
        return rows.filter(function(row) {
          return row.values[columnId].indexOf(filterValue) !== -1
        })
      }")
    )
  ),
  defaultPageSize = 5
)

## searching
data <- MASS::Cars93[1:20, c("Manufacturer", "Model", "Type", "AirBags", "Price")]

reactable(data, searchable = TRUE, minRows = 10)

# pagination
reactable(iris[1:6, ], defaultPageSize = 4)

# minRows
reactable(iris[1:6, ], defaultPageSize = 4, minRows = 4, searchable = TRUE)

# page size options
reactable(
  iris[1:12, ],
  showPageSizeOptions = TRUE,
  pageSizeOptions = c(4, 8, 12),
  defaultPageSize = 4
)

# pagination types
reactable(iris[1:50, ], paginationType = "jump", defaultPageSize = 4)
reactable(iris[1:50, ], paginationType = "simple", defaultPageSize = 4)

# page information
reactable(iris[1:12, ], showPageInfo = FALSE, defaultPageSize = 4)
reactable(iris[1:12, ], showPageInfo = FALSE, showPageSizeOptions = TRUE,
          defaultPageSize = 4)
reactable(iris[1:5, ], showPagination = TRUE)
reactable(iris[1:20, ], pagination = FALSE, highlight = TRUE, height = 250)

# grouping
data <- MASS::Cars93[10:22, c("Manufacturer", "Model", "Type", "Price", "MPG.city")]

reactable(data, groupBy = "Manufacturer")

# aggregation
data <- MASS::Cars93[14:38, c("Type", "Price", "MPG.city", "DriveTrain", "Man.trans.avail")]

reactable(
  data,
  groupBy = "Type",
  columns = list(
    Price = colDef(aggregate = "max"),
    MPG.city = colDef(aggregate = "mean", format = colFormat(digits = 1)),
    DriveTrain = colDef(aggregate = "unique"),
    Man.trans.avail = colDef(aggregate = "frequency")
  )
)

### aggregate functions available
colDef(aggregate = "sum")        # Sum of numbers
colDef(aggregate = "mean")       # Mean of numbers
colDef(aggregate = "max")        # Maximum of numbers
colDef(aggregate = "min")        # Minimum of numbers
colDef(aggregate = "median")     # Median of numbers
colDef(aggregate = "count")      # Count of values
colDef(aggregate = "unique")     # Comma-separated list of unique values
colDef(aggregate = "frequency")  # Comma-separated counts of unique values

### or
colDef(
  aggregate = JS("
    function(values, rows) {
      // input:
      //  - values: an array of all values in the group
      //  - rows: an array of row data values for all rows in the group (optional)
      //
      // output:
      //  - an aggregated value, e.g. a comma-separated list
      return values.join(', ')
    }
  ")
)


### Multiple groups
data <- data.frame(
  State = state.name,
  Region = state.region,
  Division = state.division,
  Area = state.area
)

reactable(
  data,
  groupBy = c("Region", "Division"),
  columns = list(
    Division = colDef(aggregate = "unique"),
    Area = colDef(aggregate = "sum", format = colFormat(separators = TRUE))
  ),
  bordered = TRUE
)


### Custom aggregate functions
# JS
# columns = list(
#  Price = colDef(
#    aggregate = JS("function(values, rows) {
#      values
#      // [46.8, 27.6, 57]

#      rows
#      // [
#      //   { "Model": "Dynasty", "Manufacturer": "Dodge", "Price": 46.8, "Units": 2 },
#      //   { "Model": "Colt", "Manufacturer": "Dodge", "Price": 27.6, "Units": 5 },
#      //   { "Model": "Caravan", "Manufacturer": "Dodge", "Price": 57, "Units": 5 }
#      // ]
#    }")
#  )
#)

## Custome in R
library(dplyr)

set.seed(10)

data <- sample_n(MASS::Cars93[23:40, ], 30, replace = TRUE) %>%
  mutate(Price = Price * 3, Units = sample(1:5, 30, replace = TRUE)) %>%
  mutate(Avg.Price = Price / Units) %>%
  select(Model, Manufacturer, Price, Units, Avg.Price)

reactable(
  data,
  groupBy = "Manufacturer",
  columns = list(
    Price = colDef(aggregate = "sum", format = colFormat(currency = "USD")),
    Units = colDef(aggregate = "sum"),
    Avg.Price = colDef(
      # Calculate the aggregate Avg.Price as `sum(Price) / sum(Units)`
      aggregate = JS("function(values, rows) {
        let totalPrice = 0
        let totalUnits = 0
        rows.forEach(function(row) {
          totalPrice += row['Price']
          totalUnits += row['Units']
        })
        return totalPrice / totalUnits
      }"),
      format = colFormat(currency = "USD")
    )
  )
)
