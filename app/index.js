import axios from "axios";
import * as fs from 'fs'

const getResponse = async () => {
    const response = await axios.get(
        'https://news.yahoo.co.jp/rss/topics/top-picks.xml',
        {
            headers: {
                'Cache-Control': 'no-cache',
                'Pragma': 'no-cache',
                'Expires': '0',
            },
            params: {
                t: new Date().getTime()
            }
        }
    );
    // console.log(response);
    fs.writeSync(1, response.data);
};

// 実行結果
getResponse();
