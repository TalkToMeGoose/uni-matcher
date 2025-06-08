test_that("direct match works", {
  expect_equal(
    match_unis("Uni Kassel")$canonical,
    "University of Kassel"
  )
})
