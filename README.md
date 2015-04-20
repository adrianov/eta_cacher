# ETA cacher
ETA caching service for Wheely

## Installation
    bundle install
    
    sudo apt-get install mongodb redis-server

## Usage
1. Create or update cars with `/car?id=1&lat=111&long=222&available=true`
2. Call ETA with `/eta?lat=111&long=222`
