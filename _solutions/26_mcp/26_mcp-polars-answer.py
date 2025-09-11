import polars as pl
from pyhere import here

listings = pl.read_csv(here("data/airbnb-asheville.csv"))

hot_room_types = (
    listings.group_by(["neighborhood", "room_type"])
    .agg(
        [
            pl.len().alias("total_listings"),
            pl.col("price").mean().round(2).alias("avg_price"),
            pl.col("score_rating").mean().round(2).alias("avg_rating"),
            # occupied days = 365 - availability_365
            (365 - pl.col("availability_365")).sum().alias("total_occupied_days"),
            (365 - pl.col("availability_365").mean()).alias("avg_occupied_days"),
            pl.col("n_reviews").sum().alias("total_reviews"),
        ]
    )
    .with_columns(
        (pl.col("total_reviews") / pl.col("total_listings")).alias(
            "reviews_per_listing"
        )
    )
    .group_by("neighborhood")
    .map_groups(lambda df: df.sort("reviews_per_listing", descending=True).head(1))
    .sort("avg_occupied_days", descending=True)
    .select(
        "neighborhood",
        "room_type",
        "total_listings",
        "avg_price",
        "total_occupied_days",
        "avg_occupied_days",
        "total_reviews",
        "reviews_per_listing",
    )
)

print(hot_room_types)
