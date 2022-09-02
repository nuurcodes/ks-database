CREATE OR REPLACE FUNCTION get_barcode(barcode text, company_id text) RETURNS jsonb AS
$BODY$
DECLARE
  _rec record;
  _bc text;
BEGIN
  _bc := '%' || barcode;
  SELECT pb.barcode, size, size_region, ps AS sku
  INTO _rec
  FROM product_barcode pb
  JOIN product_sku ps USING (sku)
  WHERE pb.barcode ILIKE _bc AND (pb.verified OR pb.source_id = company_id::uuid)
  ORDER BY pb.barcode
  LIMIT 1;

  RETURN to_jsonb(_rec);
END;
$BODY$ LANGUAGE plpgsql;