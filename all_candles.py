from decimal import Decimal
import os
from dotenv import load_dotenv
from datetime import timedelta

from tinkoff.invest import CandleInterval, Client
from tinkoff.invest.schemas import CandleSource
from tinkoff.invest.utils import now
from pandas import DataFrame

load_dotenv()

TOKEN = os.environ["PROD_INVEST_TOKEN"]


def main():
    with Client(TOKEN) as client:
        candles = client.get_all_candles(
            instrument_id="BBG004730N88",
            from_=now() - timedelta(days=1),
            interval=CandleInterval.CANDLE_INTERVAL_5_MIN,
            candle_source_type=CandleSource.CANDLE_SOURCE_UNSPECIFIED,
        )

        df = DataFrame([{'time': c.time, 'price': Decimal(f'{c.close.units}.{c.close.nano}'), 'volume': c.volume} for c in candles])
        df['MA_100'] = df['price'].rolling(window=100).mean()    
        df['MA_12'] = df['price'].rolling(window=12).mean()    
        print(df)
        

    return 0


if __name__ == "__main__":
    main()