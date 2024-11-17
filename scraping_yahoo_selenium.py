from selenium import webdriver
from selenium.webdriver.edge.service import Service
from webdriver_manager.microsoft import EdgeChromiumDriverManager
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.common.by import By
from datetime import datetime, timezone, date
from selenium.webdriver.support import expected_conditions as EC
import openpyxl
import time

HEADER_ARRAY_OPT = ["ContractID", "LastTrTime", "Strike", "LastPr", "Bid", "Ask", "PrChg", "PrChgPct", "Vol", "OI", "ImplVol"]
HEADER_ARRAY_HIS = ["Date", "Open", "High", "Low", "Close", "Adj_Close", "Volume"]

def convert_date_to_epoch(data_str, date_format='%Y-%m-%d'):
    dt = datetime.strptime(data_str, date_format)
    utc_dt = dt.replace(tzinfo=timezone.utc)
    epoch_timestamp = int(utc_dt.timestamp())
    return epoch_timestamp

def scrape_data_with_selenium(url, output_excel, header):
    # Configura il driver
    options = webdriver.EdgeOptions()
    options.use_chromium = True  # Necessario per Edge Chromium

    driver_service = Service(EdgeChromiumDriverManager().install())
    driver = webdriver.Edge(service=driver_service, options=options)

    try:
        # Apri l'URL
        driver.get(url)

        time.sleep(5)

	# Aspetta che il popup dei cookie appaia e clicca su "Accetta" (cambia il selettore se necessario)
        try:
            # Modifica il selettore in base al sito specifico
            cookie_button = WebDriverWait(driver, 10).until(
		EC.element_to_be_clickable(driver.find_element(By.ID, "scroll-down-btn"))
            )
            cookie_button.click()
            cookie_button = WebDriverWait(driver, 10).until(
                EC.element_to_be_clickable(driver.find_element(By.NAME, "agree"))
            )
            cookie_button.click()
        except Exception as e:
            print("Popup dei cookie non trovato o errore nell'interazione:", e)
	
	# Aspetta un po' prima di chiudere il browser
        #input("Premi invio per chiudere il browser...")

        # Trova la tabella
        table = driver.find_element(By.TAG_NAME, "table")
        rows = table.find_elements(By.TAG_NAME, "tr")

        wb = openpyxl.Workbook()
        ws = wb.active
        ws.append(header)

        r=[]

        for row in rows:
            cells = row.find_elements(By.TAG_NAME, "td")
            if cells:
                # Aggiungi i dati delle celle
                r.append([cell.text.strip().replace(",", "") for cell in cells])

        r.reverse()

        for row in r:
                ws.append(row)

        # Salva il file Excel
        wb.save(output_excel)
        print(f"Dati salvati in {output_excel}")

    except Exception as e:
        print(f"Errore durante lo scraping: {e}")
    
    finally:
        driver.quit()  # Assicurati di chiudere il driver

def scrape_data(date_str, calls_or_puts):
    output_excel = f"{calls_or_puts}/SPX_Opt_{calls_or_puts}_{date.today()}.xlsx"
    epoch_timestamp = convert_date_to_epoch(date_str)
    url = f"https://finance.yahoo.com/quote/%5ESPX/options/?date={epoch_timestamp}&type={calls_or_puts}"
    scrape_data_with_selenium(url, output_excel, HEADER_ARRAY_OPT)

def get_historical_prices(start_date_str, end_date_str):
    output_excel = f"SPX_historical_prices_{start_date_str}_{end_date_str}.xlsx"
    start_epoch_timestamp = convert_date_to_epoch(start_date_str)
    end_epoch_timestamp = convert_date_to_epoch(end_date_str)
    url = f"https://finance.yahoo.com/quote/%5ESPX/history/?period1={start_epoch_timestamp}&period2={end_epoch_timestamp}"
    print(url)
    
    scrape_data_with_selenium(url, output_excel, HEADER_ARRAY_HIS)

# Impostare qui le date
date_str = "2024-10-10"
start_date = "2021-09-23"
end_date = "2024-09-23"

scrape_data(date_str, "calls")
scrape_data(date_str, "puts")
#get_historical_prices(start_date, end_date)
