---
description: "When user asks about news trends, hot topics, RSS feeds, or wants to analyze/search recent news — use the TrendRadar MCP tools"
allowed-tools:
  - mcp__trendradar__get_latest_news
  - mcp__trendradar__get_trending_topics
  - mcp__trendradar__search_news
  - mcp__trendradar__analyze_topic_trend
  - mcp__trendradar__analyze_data_insights
  - mcp__trendradar__analyze_sentiment
  - mcp__trendradar__find_related_news
  - mcp__trendradar__generate_summary_report
  - mcp__trendradar__get_latest_rss
  - mcp__trendradar__search_rss
  - mcp__trendradar__read_article
  - mcp__trendradar__read_articles_batch
  - mcp__trendradar__aggregate_news
  - mcp__trendradar__compare_periods
  - mcp__trendradar__send_notification
  - mcp__trendradar__trigger_crawl
  - mcp__trendradar__resolve_date_range
---

# TrendRadar — News Trend Intelligence

Use the TrendRadar MCP server for all news aggregation, trend analysis, and notification tasks.

## Available Tools (27)

### Data Query
- `get_latest_news` — Fetch the most recent news articles
- `get_news_by_date` — Get news for a specific date
- `search_news` — Full-text search across all collected news
- `aggregate_news` — Aggregate news by topic/source/date

### Trend Analysis
- `get_trending_topics` — Current trending topics across sources
- `analyze_topic_trend` — Track how a topic trends over time
- `analyze_data_insights` — Statistical insights from news data
- `analyze_sentiment` — Sentiment analysis on news topics
- `find_related_news` — Find articles related to a topic
- `compare_periods` — Compare news patterns between time periods
- `generate_summary_report` — Generate a comprehensive trend report

### RSS
- `get_latest_rss` — Latest RSS feed entries
- `search_rss` — Search within RSS feeds
- `get_rss_feeds_status` — Check RSS feed health

### Article Reading
- `read_article` — Read full article content
- `read_articles_batch` — Read multiple articles at once

### System
- `trigger_crawl` — Trigger a news crawl manually
- `get_system_status` — Check TrendRadar system health
- `check_version` — Check for updates
- `get_current_config` — View current configuration
- `resolve_date_range` — Parse natural language date ranges

### Storage & Sync
- `sync_from_remote` — Sync data from remote storage
- `get_storage_status` — Check storage health
- `list_available_dates` — List dates with available data

### Notifications
- `send_notification` — Send news digest to configured channels
- `get_notification_channels` — List notification channels
- `get_channel_format_guide` — Get formatting guide for a channel

## Workflow Examples

**Daily briefing:**
1. `get_trending_topics` → see what's hot
2. `get_latest_news` → read top stories
3. `generate_summary_report` → create digest
4. `send_notification` → push to Slack/WeChat/email

**Research a topic:**
1. `search_news "AI agents"` → find relevant articles
2. `analyze_topic_trend "AI agents"` → see trend over time
3. `analyze_sentiment "AI agents"` → gauge market sentiment
4. `read_articles_batch` → deep-read the top hits

## Prerequisites

- Python 3.12+
- `uvx` (for running the MCP server)
- TrendRadar data (run `trendradar` crawler first, or sync from remote)
