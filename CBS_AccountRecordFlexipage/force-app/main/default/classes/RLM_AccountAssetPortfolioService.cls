global with sharing class RLM_AccountAssetPortfolioService {

    // ----------------------------------------------------
    // WRAPPERS
    // ----------------------------------------------------
    global class PortfolioResponse {
        @AuraEnabled public List<AssetWrapper> assets;
        @AuraEnabled public List<PointWrapper> points;

        public PortfolioResponse() {
            assets = new List<AssetWrapper>();
            points = new List<PointWrapper>();
        }
    }

    global class AssetWrapper {
        @AuraEnabled public Id id;
        @AuraEnabled public String name;
        @AuraEnabled public String productName;
    }

    global class PointWrapper {
        @AuraEnabled public Id assetId;
        @AuraEnabled public String startDate; // yyyy-MM-dd (string, not date)
        @AuraEnabled public Decimal quantity;
        @AuraEnabled public Decimal mrr;
    }


    // ----------------------------------------------------
    // SAFE DATE → STRING (NO format() USED)
    // ----------------------------------------------------
    private static String toIsoDate(Date d) {
        if (d == null) return null;

        Integer y = d.year();
        Integer m = d.month();
        Integer day = d.day();

        // pad month/day to always be 2-digits
        String mm  = (m < 10 ? '0' + String.valueOf(m) : String.valueOf(m));
        String dd  = (day < 10 ? '0' + String.valueOf(day) : String.valueOf(day));

        return y + '-' + mm + '-' + dd;
    }


    // ----------------------------------------------------
    // MAIN METHOD — MRR & QUANTITY ONLY
    // ----------------------------------------------------
    @AuraEnabled(cacheable=true)
    global static PortfolioResponse getAccountAssetTimeline(Id accountId) {
        PortfolioResponse resp = new PortfolioResponse();
        if (accountId == null) return resp;

        // 1) Load Assets
        List<Asset> assets = [
            SELECT Id, Name, Product2.Name
            FROM Asset
            WHERE AccountId = :accountId
        ];
        if (assets.isEmpty()) return resp;

        Map<Id, AssetWrapper> assetMap = new Map<Id, AssetWrapper>();

        for (Asset a : assets) {
            AssetWrapper aw = new AssetWrapper();
            aw.id = a.Id;
            aw.name = a.Name;
            aw.productName = (a.Product2 != null ? a.Product2.Name : null);

            resp.assets.add(aw);
            assetMap.put(a.Id, aw);
        }

        // 2) Load State Periods
        List<AssetStatePeriod> periods = [
            SELECT AssetId, StartDate, Quantity, Mrr
            FROM AssetStatePeriod
            WHERE AssetId IN :assetMap.keySet()
            ORDER BY StartDate ASC
        ];

        // 3) Convert periods → timeline points
        for (AssetStatePeriod p : periods) {
            if (p.StartDate == null) continue;

            Date d = p.StartDate.date();

            PointWrapper pt = new PointWrapper();
            pt.assetId   = p.AssetId;
            pt.startDate = toIsoDate(d);   // SAFE STRING
            pt.quantity  = p.Quantity;
            pt.mrr       = p.Mrr;

            resp.points.add(pt);
        }

        return resp;
    }
}