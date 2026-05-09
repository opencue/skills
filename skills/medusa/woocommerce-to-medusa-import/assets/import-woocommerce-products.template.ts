import fs from "fs"
import os from "os"
import path from "path"

import { ContainerRegistrationKeys } from "@medusajs/framework/utils"
import { createProductsWorkflow, linkProductsToSalesChannelWorkflow } from "@medusajs/medusa/core-flows"

type ImportOptions = {
  dryRun: boolean
  limit?: number
  currency: string
}

const GLOBAL_ENV_PATH = path.join(os.homedir(), ".config", "woocommerce-medusa-import", "env")

function loadGlobalWooEnv() {
  if (!fs.existsSync(GLOBAL_ENV_PATH)) {
    return
  }

  const raw = fs.readFileSync(GLOBAL_ENV_PATH, "utf8")
  for (const line of raw.split(/\r?\n/)) {
    const trimmed = line.trim()
    if (!trimmed || trimmed.startsWith("#")) {
      continue
    }

    const match = trimmed.match(/^([A-Z0-9_]+)=(.*)$/)
    if (!match) {
      continue
    }

    const [, key, value] = match
    if (!process.env[key]) {
      process.env[key] = value.replace(/^['"]|['"]$/g, "")
    }
  }
}

function parseArgs(argv: string[]): ImportOptions {
  const options: ImportOptions = { dryRun: true, currency: "eur" }

  for (let i = 0; i < argv.length; i += 1) {
    const arg = argv[i]
    if (arg === "--live") options.dryRun = false
    if (arg === "--dry-run") options.dryRun = true
    if (arg === "--limit") options.limit = Number(argv[++i])
    if (arg === "--currency") options.currency = argv[++i]
  }

  return options
}

async function fetchWooProducts(_options: ImportOptions) {
  const url = process.env.WOOCOMMERCE_URL
  const key = process.env.WOOCOMMERCE_CONSUMER_KEY
  const secret = process.env.WOOCOMMERCE_CONSUMER_SECRET

  if (!url || !key || !secret) {
    throw new Error(
      `Missing WooCommerce credentials. Set env vars or ${GLOBAL_ENV_PATH}`
    )
  }

  throw new Error("TODO: implement paginated WooCommerce fetch")
}

export default async function importWooCommerceProducts({ container }) {
  loadGlobalWooEnv()

  const options = parseArgs(process.argv.slice(2))
  const logger = container.resolve(ContainerRegistrationKeys.LOGGER)
  const query = container.resolve(ContainerRegistrationKeys.QUERY)

  const wooProducts = await fetchWooProducts(options)

  const { data: existingProducts } = await query.graph({
    entity: "product",
    fields: ["id", "handle", "metadata", "variants.id", "variants.sku", "variants.metadata"],
  })

  logger.info(`Woo products read: ${wooProducts.length}`)
  logger.info(`Existing Medusa products read: ${existingProducts.length}`)
  logger.info(`Dry run: ${options.dryRun}`)

  if (options.dryRun) {
    return
  }

  // TODO: map Woo products to Medusa create/update inputs.
  // Use createProductsWorkflow for creates and product update workflows for updates.
  const productsToCreate = []

  if (productsToCreate.length > 0) {
    const { result: createdProducts } = await createProductsWorkflow(container).run({
      input: { products: productsToCreate },
    })

    // TODO: resolve target sales channel ID from store/default sales channel.
    const salesChannelId = "TODO"
    await linkProductsToSalesChannelWorkflow(container).run({
      input: {
        id: salesChannelId,
        add: createdProducts.map((product) => product.id),
      },
    })
  }
}
