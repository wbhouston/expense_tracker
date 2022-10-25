# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...

## Basic Model Overview
- Account (i.e. the accounts in the Chart of Accounts)
  - name
  - type (asset, investment, liability, revenue, expense)
  - type number (prefix for account numbers)
  - number
  - credit or debit?
    - might be based on type

- Transaction
  - date
  - account debited
  - account credited
  - memo
  - note
  - amount
  - percent shared
  - imported transaction id

- Import
  - file
  - column mappings
  - transactions imported
  - transaction amount type (separate columns/negative to credited or debited)

- Column Mapping
  - from column
  - to field
  - credit or debit
