import polars as pl
from pyhere import here

df = pl.read_csv(here("data/penguins.csv"))

island_summary = (
    df.group_by("island")
    .agg(
        sample_size=pl.len(),
        prop_female=(pl.col("sex").eq("female").sum() / pl.col("sex").len()),
        mean_bill_depth_mm=pl.col("bill_depth_mm").mean(),
        std_bill_depth_mm=pl.col("bill_depth_mm").std(),
        mean_flipper_length_mm=pl.col("flipper_length_mm").mean(),
        std_flipper_length_mm=pl.col("flipper_length_mm").std(),
        mean_body_mass_g=pl.col("body_mass_g").mean(),
        std_body_mass_g=pl.col("body_mass_g").std(),
    )
    .sort("island")
)

island_summary
