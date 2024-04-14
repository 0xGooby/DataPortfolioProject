import requests
from bs4 import BeautifulSoup
import pandas as pd

def scrape_wiki():
    url = "https://en.wikipedia.org/wiki/List_of_largest_companies_in_the_United_States_by_revenue"
    response = requests.get(url)
    if response.status_code == 200:
        soup = BeautifulSoup(response.text, 'html.parser')
        table = soup.find_all("table")[1]
        world_titles = table.find_all("th")
        world_table_titles = [title.text.strip() for title in world_titles]
        df = pd.DataFrame(columns = world_table_titles)
        column_data = table.find_all('tr')
        for row in column_data[1:]:
            row_data = row.find_all('td')
            indiv_row_data = [data.text.strip() for data in row_data]
            
            length = len(df)
            df.loc[length] = indiv_row_data
        print(df)
        # df.to_csv(r"C:\Users\Alex Pc\Downloads\Coding Projects\Python Projects\Data Analyst\Test csv files\Wiki_data.csv")

    else:
        print("Failed to retrieve wiki data.")

if __name__ == "__main__":
    scrape_wiki()


