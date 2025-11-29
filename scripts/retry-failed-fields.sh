#!/usr/bin/env bash
# Retry adding failed fields

VAULT_ID="y5l42cppvgu22o2obesu4ctla4"
ITEM_ID="yshcei6tjnutzbow46mx5ypu3y"

echo -n "Adding ANTHROPIC_API_KEY... "
if op item edit "$ITEM_ID" --vault "$VAULT_ID" "custom.ANTHROPIC_API_KEY[CONCEALED]=\$CLAUDE_API_KEY" > /dev/null 2>&1; then
    echo "✓"
else
    echo "✗"
fi
sleep 0.3

echo -n "Adding SEC_API_KEY... "
if op item edit "$ITEM_ID" --vault "$VAULT_ID" "custom.SEC_API_KEY[CONCEALED]=8295abee3be12b55a179a469fc981d90c2dd6cb4a420c9041262ab16820f0ec2" > /dev/null 2>&1; then
    echo "✓"
else
    echo "✗"
fi
sleep 0.3

echo -n "Adding LINKEDIN_EMAIL... "
if op item edit "$ITEM_ID" --vault "$VAULT_ID" "custom.LINKEDIN_EMAIL[CONCEALED]=aculich@gmail.com" > /dev/null 2>&1; then
    echo "✓"
else
    echo "✗"
fi
sleep 0.3

echo -n "Adding LINKEDIN_PASSWORD... "
if op item edit "$ITEM_ID" --vault "$VAULT_ID" "custom.LINKEDIN_PASSWORD[CONCEALED]=8kq%cIyZ7UN\!OH#\!Ouii9\$7wS\$6PemlajxPPslze" > /dev/null 2>&1; then
    echo "✓"
else
    echo "✗"
fi
sleep 0.3

echo -n "Adding DNSIMPLE_API_KEY... "
if op item edit "$ITEM_ID" --vault "$VAULT_ID" "custom.DNSIMPLE_API_KEY[CONCEALED]=dnsimple_u_uZLygl9Uj7HKy7sOa605LmYDdXQMH9cO" > /dev/null 2>&1; then
    echo "✓"
else
    echo "✗"
fi
sleep 0.3

echo -n "Adding DNSIMPLE_API_ACCOUNT... "
if op item edit "$ITEM_ID" --vault "$VAULT_ID" "custom.DNSIMPLE_API_ACCOUNT[CONCEALED]=17033" > /dev/null 2>&1; then
    echo "✓"
else
    echo "✗"
fi
sleep 0.3

echo -n "Adding FIRECRAWL_API_KEY... "
if op item edit "$ITEM_ID" --vault "$VAULT_ID" "custom.FIRECRAWL_API_KEY[CONCEALED]=fc-1329d663d8304feca6cc7d3f145f63c5" > /dev/null 2>&1; then
    echo "✓"
else
    echo "✗"
fi
sleep 0.3

echo -n "Adding CONGRESS_API_KEY... "
if op item edit "$ITEM_ID" --vault "$VAULT_ID" "custom.CONGRESS_API_KEY[CONCEALED]=A9SrhD6KfZUh8cqmQtB9tceU5haal58vM27GK0Xs" > /dev/null 2>&1; then
    echo "✓"
else
    echo "✗"
fi
sleep 0.3

echo -n "Adding LEGALSERVER_USERNAME... "
if op item edit "$ITEM_ID" --vault "$VAULT_ID" "custom.LEGALSERVER_USERNAME[CONCEALED]=api" > /dev/null 2>&1; then
    echo "✓"
else
    echo "✗"
fi
sleep 0.3

echo -n "Adding LEGALSERVER_PASSWORD... "
if op item edit "$ITEM_ID" --vault "$VAULT_ID" "custom.LEGALSERVER_PASSWORD[CONCEALED]=vzi08GExOSZXHM0F" > /dev/null 2>&1; then
    echo "✓"
else
    echo "✗"
fi
sleep 0.3

echo -n "Adding BASEROW_API_KEY_LOCAL_RRID... "
if op item edit "$ITEM_ID" --vault "$VAULT_ID" "custom.BASEROW_API_KEY_LOCAL_RRID[CONCEALED]=a6mZfHbdMriAoqeJYNj6bKgDXnK7ZQVN" > /dev/null 2>&1; then
    echo "✓"
else
    echo "✗"
fi
sleep 0.3

echo -n "Adding LIMITLESS_API_KEY... "
if op item edit "$ITEM_ID" --vault "$VAULT_ID" "custom.LIMITLESS_API_KEY[CONCEALED]=sk-e876476c-7396-4c01-a9d5-f8a625ab6cc4" > /dev/null 2>&1; then
    echo "✓"
else
    echo "✗"
fi
sleep 0.3

echo -n "Adding BRAVE_API_KEY... "
if op item edit "$ITEM_ID" --vault "$VAULT_ID" "custom.BRAVE_API_KEY[CONCEALED]=BSAQgcdZ_J5VZvpcE55V0IJgT4cu03f" > /dev/null 2>&1; then
    echo "✓"
else
    echo "✗"
fi
sleep 0.3

echo -n "Adding BRAVE_AI_API_KEY... "
if op item edit "$ITEM_ID" --vault "$VAULT_ID" "custom.BRAVE_AI_API_KEY[CONCEALED]=BSA64Gcqrx-DoOJYPj4GEY7Gzawu50a" > /dev/null 2>&1; then
    echo "✓"
else
    echo "✗"
fi
sleep 0.3

echo -n "Adding FLOURISH_API_KEY... "
if op item edit "$ITEM_ID" --vault "$VAULT_ID" "custom.FLOURISH_API_KEY[CONCEALED]=G8cx7gGTlFEbk0WVP9cSR7wBIR1rZZvj2h1ULPC5aty_erc2O6Qjh4yZcDaMtxPP" > /dev/null 2>&1; then
    echo "✓"
else
    echo "✗"
fi
sleep 0.3

echo -n "Adding YOUTUBE_API_KEY... "
if op item edit "$ITEM_ID" --vault "$VAULT_ID" "custom.YOUTUBE_API_KEY[CONCEALED]=AIzaSyBgWFOrgJjRKDHCcISRb40Io704sizDMJU" > /dev/null 2>&1; then
    echo "✓"
else
    echo "✗"
fi
sleep 0.3

echo -n "Adding PUBPUB_API_ENDPOINT... "
if op item edit "$ITEM_ID" --vault "$VAULT_ID" "custom.PUBPUB_API_ENDPOINT[CONCEALED]=https://app.pubpub.org" > /dev/null 2>&1; then
    echo "✓"
else
    echo "✗"
fi
sleep 0.3

