-- testeo de calidad de segmentación

with vivs_sgms as (
    select frac, radio, sgm, count(*) as vivs_sgm
    from comuna11
    group by frac, radio, sgm
    ), 
    cant_segs as (
    select frac, radio, count(*) as sgms, min(vivs_sgm), max(vivs_sgm), sum(vivs_sgm) as vivs
    from vivs_sgms
    group by frac, radio
    )
select *, round(vivs/40.0) as esperada
from cant_segs
order by frac, radio
;


