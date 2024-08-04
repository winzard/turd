from decimal import Decimal
import os
from dotenv import load_dotenv
from datetime import timedelta

from tinkoff.invest import CandleInterval, Client
from tinkoff.invest.schemas import CandleSource
from tinkoff.invest.utils import now
import numpy as np
import pandas as pd
from numpy_ext import rolling_apply as rolling_apply_ext

load_dotenv()

TOKEN = os.environ["PROD_INVEST_TOKEN"]
# https://stackoverflow.com/questions/60736556/pandas-rolling-apply-using-multiple-columns
def masscenter(price, volume):
    return np.sum(price * volume) / np.sum(volume)


def main():
    with Client(TOKEN) as client:
        candles = client.get_all_candles(
            instrument_id="BBG004730N88",
            from_=now() - timedelta(days=1),
            interval=CandleInterval.CANDLE_INTERVAL_5_MIN,
            candle_source_type=CandleSource.CANDLE_SOURCE_UNSPECIFIED,
        )

        df = pd.DataFrame([{'time': c.time, 'price': Decimal(f'{c.close.units}.{c.close.nano}'), 'volume': c.volume} for c in candles])
        df['MA_100'] = rolling_apply_ext(masscenter, 100 , df.price.values, df.volume.values)
        df['MA_12'] = rolling_apply_ext(masscenter, 12 , df.price.values, df.volume.values)
        
        print(df)
        

    return 0


if __name__ == "__main__":
    main()