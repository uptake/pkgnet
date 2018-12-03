# S4 Class Definitions for testing

setClass(
    Class = "KingOfTheFields"
)

setClass(
    Class = "KingOfTheTown"
)

setClass(
    Class = "KingOfTheEarth",
    contains = c("KingOfTheTown", "KingOfTheFields")
)

setClass(
    Class = "KingOfTheSky",
    contains = c("KingOfTheEarth")
)
