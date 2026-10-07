"use client";

import { createContext, useCallback, useContext, useState } from "react";
import {
  DEFAULT_DISTRICT_NAME,
  DEFAULT_REGION_NAME,
  findDistrict,
  findRegion,
} from "./uzbekistan-regions";

const REGION_KEY = "nv_region";
const DISTRICT_KEY = "nv_district";

interface LocationContextValue {
  regionName: string;
  districtName: string;
  latitude: number;
  longitude: number;
  setRegion: (name: string) => void;
  setDistrict: (name: string) => void;
}

const LocationContext = createContext<LocationContextValue | null>(null);

function readStored(key: string, fallback: string): string {
  if (typeof window === "undefined") return fallback;
  return window.localStorage.getItem(key) ?? fallback;
}

export function LocationProvider({ children }: { children: React.ReactNode }) {
  const [regionName, setRegionName] = useState(() => readStored(REGION_KEY, DEFAULT_REGION_NAME));
  const [districtName, setDistrictName] = useState(() =>
    readStored(DISTRICT_KEY, DEFAULT_DISTRICT_NAME)
  );

  const setRegion = useCallback((name: string) => {
    setRegionName(name);
    window.localStorage.setItem(REGION_KEY, name);
    const firstDistrict = findRegion(name)?.districts[0];
    if (firstDistrict) {
      setDistrictName(firstDistrict.name);
      window.localStorage.setItem(DISTRICT_KEY, firstDistrict.name);
    }
  }, []);

  const setDistrict = useCallback((name: string) => {
    setDistrictName(name);
    window.localStorage.setItem(DISTRICT_KEY, name);
  }, []);

  const district =
    findDistrict(regionName, districtName) ??
    findRegion(regionName)?.districts[0] ??
    findDistrict(DEFAULT_REGION_NAME, DEFAULT_DISTRICT_NAME)!;

  return (
    <LocationContext.Provider
      value={{
        regionName,
        districtName: district.name,
        latitude: district.latitude,
        longitude: district.longitude,
        setRegion,
        setDistrict,
      }}
    >
      {children}
    </LocationContext.Provider>
  );
}

export function useLocation() {
  const ctx = useContext(LocationContext);
  if (!ctx) throw new Error("useLocation must be used within LocationProvider");
  return ctx;
}
